provider "aws" {
  region = var.aws_region
}

# -----------------------------------------
# Latest Amazon Linux 2023 AMI
# -----------------------------------------
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# CloudFront requires ACM certificates to reside in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "vpc" {
  source             = "../../../modules/vpc"
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  environment        = var.environment
  single_nat_gateway = var.single_nat_gateway
}

module "security_groups" {
  source      = "../../../modules/security_groups"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  app_port    = 80
  db_port     = 3306
}

module "alb" {
  source                = "../../../modules/alb"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  domain_name           = var.domain_name
  certificate_domain    = var.certificate_domain
  environment           = var.environment
  app_port              = 80
}

module "cloudfront" {
  source             = "../../../modules/cloudfront"
  alb_dns_name       = module.alb.alb_dns_name
  origin_domain_name = aws_route53_record.alb_origin.fqdn
  domain_name        = var.domain_name
  certificate_domain = var.certificate_domain
  environment        = var.environment

  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}

# Fetch existing Route 53 Hosted Zone
data "aws_route53_zone" "primary" {
  name         = var.hosted_zone_name
  private_zone = false
}

# Route 53 Alias Record pointing your domain to CloudFront
resource "aws_route53_record" "cdn_alias" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.cloudfront.cloudfront_domain_name
    zone_id                = module.cloudfront.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# -----------------------------------------
# Route 53 Alias Record for CloudFront Origin
# -----------------------------------------

resource "aws_route53_record" "alb_origin" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "origin.rufneem.xyz"
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = false
  }
}


# -----------------------------------------
# EC2 Compute Module
# -----------------------------------------

module "compute" {
  source = "../../../modules/compute"

  environment           = var.environment
  private_subnet_ids    = module.vpc.private_app_subnet_ids
  app_security_group_id = module.security_groups.app_security_group_id
  target_group_arn      = module.alb.target_group_arn

  ami_id                = data.aws_ssm_parameter.al2023_ami.value
  instance_profile_name = aws_iam_instance_profile.ec2.name

  instance_type    = "t3.micro"
  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  efs_file_system_id = module.efs.efs_file_system_id


  depends_on = [
    module.efs
  ]

}

# -----------------------------------------
# CloudWatch and SNS Monitoring Module
# -----------------------------------------

module "monitoring" {
  source = "../../../modules/monitoring"

  environment = var.environment

  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix

  db_instance_id = module.rds.db_instance_id

  alert_email = var.alert_email
}


module "rds" {
  source = "../../../modules/rds"

  environment          = var.environment
  db_subnet_group_name = module.vpc.db_subnet_group_name
  db_security_group_id = module.security_groups.db_security_group_id

  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  db_name     = "utcportal"
  db_username = "utcadmin"
}


# -----------------------------------------
# Amazon EFS Module
# -----------------------------------------

module "efs" {
  source = "../../../modules/efs"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id

  private_subnet_ids    = module.vpc.private_app_subnet_ids
  app_security_group_id = module.security_groups.app_security_group_id
}