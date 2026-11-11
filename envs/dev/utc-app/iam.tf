
# -----------------------------------------
# EC2 IAM Role
# -----------------------------------------

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.environment}-utc-app-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Allow EC2 instances to use AWS Systems Manager
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.environment}-utc-app-ec2-profile"
  role = aws_iam_role.ec2.name
}


# -----------------------------------------
# Allow EC2 to read the RDS-managed secret
# -----------------------------------------

data "aws_iam_policy_document" "rds_secret_access" {
  statement {
    sid = "ReadRDSSecret"

    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      module.rds.db_secret_arn
    ]
  }
}

resource "aws_iam_role_policy" "rds_secret_access" {
  name   = "${var.environment}-utc-rds-secret-access"
  role   = aws_iam_role.ec2.id
  policy = data.aws_iam_policy_document.rds_secret_access.json
}
