# 1. ALB Security Group (Public-facing)
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Allow inbound web traffic to the Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow inbound HTTP traffic from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow inbound HTTPS traffic from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Allow outbound traffic from ALB to App servers"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.app_port
  ip_protocol                  = "tcp"
  to_port                      = var.app_port
}

# 2. App Tier Security Group (Private EC2)
resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Allow inbound traffic exclusively from ALB and outbound access for updates/DB"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.environment}-app-sg"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow app traffic exclusively from ALB Security Group"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.app_port
  ip_protocol                  = "tcp"
  to_port                      = var.app_port
}

resource "aws_vpc_security_group_egress_rule" "app_outbound_internet" {
  security_group_id = aws_security_group.app.id
  description       = "Allow outbound internet access (via NAT Gateway) for OS updates and external APIs"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 3. Database Tier Security Group (Isolated RDS)
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Allow inbound database traffic exclusively from App servers"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "Allow DB connection exclusively from App Security Group"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.db_port
  ip_protocol                  = "tcp"
  to_port                      = var.db_port
}

# Note: RDS Security Group has no outbound egress rule to ensure strict isolation.