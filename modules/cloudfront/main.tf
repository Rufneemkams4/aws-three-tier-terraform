# AWS Provider requirement for ACM Certificate lookup in us-east-1 (CloudFront requirement)
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.us_east_1]
    }
  }
}

# 1. Fetch Existing ACM Certificate in us-east-1 for CloudFront
data "aws_acm_certificate" "cloudfront_cert" {
  provider    = aws.us_east_1
  domain      = var.certificate_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

# 2. CloudFront Distribution using ALB as Origin
resource "aws_cloudfront_distribution" "this" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.environment} CloudFront CDN in front of ALB"
  aliases         = [var.domain_name]
  price_class     = "PriceClass_100" # Lowest cost tier (US, Canada, Europe)

  origin {
    domain_name = var.origin_domain_name
    origin_id   = "ALB-${var.environment}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only" # Secure HTTPS communication from CloudFront to ALB
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALB-${var.environment}"

    # Caching disabled by default for dynamic 3-tier API backend (Forward all headers/cookies/query strings)
    # Switch to CachingOptimized managed policy if serving static assets
    forwarded_values {
      query_string = true
      headers = [
        "Accept",
        "Accept-Language",
        "Authorization",
        "Origin"
      ]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cloudfront_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name        = "${var.environment}-cloudfront"
    Environment = var.environment
  }
}