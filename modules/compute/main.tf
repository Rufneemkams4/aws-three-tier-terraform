
# -----------------------------------------
# EC2 Launch Template
# -----------------------------------------

resource "aws_launch_template" "app" {
  name_prefix   = "${var.environment}-utc-app-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  # EC2 IAM permissions
  iam_instance_profile {
    name = var.instance_profile_name
  }

  # Application security group
  vpc_security_group_ids = [
    var.app_security_group_id
  ]

  # Encrypt the root EBS volume
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }


  # Startup script
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euxo pipefail

    # -----------------------------------------
    # Install Nginx and Amazon EFS utilities
    # -----------------------------------------
    dnf install -y nginx amazon-efs-utils

    # -----------------------------------------
    # Configure EFS shared storage
    # -----------------------------------------
    mkdir -p /mnt/efs

    #------------------------------------------
    # Persist EFS mount across reboots
    #------------------------------------------
    echo "${var.efs_file_system_id}:/ /mnt/efs efs _netdev,tls,nofail 0 0" >> /etc/fstab
    #------------------------------------------
    # Mount EFS using TLS encryption
    # Retry because mount targets or DNS may not be ready

    EFS_MOUNTED=false

    for attempt in 1 2 3 4 5; do
      if mount -a -t efs; then
        echo "EFS mounted successfully"
        EFS_MOUNTED=true
        break
     fi

      echo "EFS mount attempt $attempt failed. Retrying..."
      sleep 15
    done

    if [ "$EFS_MOUNTED" = false ]; then
      echo "WARNING: EFS mount failed. Continuing startup."
    fi


    # -----------------------------------------
    # Configure Nginx application
    # -----------------------------------------
    mkdir -p /usr/share/nginx/html

    echo "UTC Student Services Portal - ${var.environment}" > /usr/share/nginx/html/index.html

    echo "OK" > /usr/share/nginx/html/health

    systemctl enable nginx
    systemctl start nginx
  EOF
  )

  monitoring {
    enabled = false
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.environment}-utc-app"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


# -----------------------------------------
# EC2 Auto Scaling Group
# -----------------------------------------

resource "aws_autoscaling_group" "app" {
  name_prefix = "${var.environment}-utc-app-asg-"

  # EC2 capacity
  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size

  # Deploy instances into private app subnets
  vpc_zone_identifier = var.private_subnet_ids

  # Use our existing EC2 Launch Template
  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  # Register EC2 instances with the existing ALB
  target_group_arns = [var.target_group_arn]

  # Use ALB health checks
  health_check_type         = "ELB"
  health_check_grace_period = 300

  # Allow EC2 instances time to initialize
  default_instance_warmup = 180

  # Wait until at least one instance is healthy
  # during Terraform creation
  min_elb_capacity          = 1
  wait_for_capacity_timeout = "15m"

  tag {
    key                 = "Name"
    value               = "${var.environment}-utc-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
