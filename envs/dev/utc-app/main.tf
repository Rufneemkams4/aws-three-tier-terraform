provider "aws" {
  region = var.aws_region
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
  environment           = var.environment
  app_port              = 80
}

module "cloudfront" {
  source       = "../../../modules/cloudfront"
  alb_dns_name = module.alb.alb_dns_name
  domain_name  = var.domain_name
  environment  = var.environment

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