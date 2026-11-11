# UTC Student Services Portal — AWS Infrastructure as Code

A modular AWS infrastructure project built using **Terraform**, designed to host a scalable, secure, and highly available Student Services Portal.

This project demonstrates practical skills in AWS cloud architecture, Infrastructure as Code (IaC), networking, security, compute, storage, database management, and infrastructure monitoring.

## 1. Project Overview

The UTC Student Services Portal infrastructure is designed around a three-tier AWS architecture:

- **Presentation and delivery:** Amazon CloudFront, Amazon Route 53, and an Application Load Balancer (ALB).
- **Application tier:** Amazon EC2 instances managed by an Auto Scaling Group, running Nginx.
- **Data tier:** Amazon RDS for MySQL and Amazon Elastic File System (EFS).

Terraform provisions and connects the infrastructure components through reusable modules.

**Current status:** Infrastructure configuration validated and planned. The AWS environment has not yet been deployed as part of this project review. The EC2 bootstrap configuration serves an Nginx placeholder page; the complete student portal application is not yet implemented.

## 2. AWS Architecture

```text
                         Internet Users
                               |
                               v
                     Amazon Route 53
                    portal.rufneem.xyz
                               |
                               v
                       Amazon CloudFront
                         HTTPS / TLS
                               |
                               v
                    origin.rufneem.xyz
                               |
                               v
                    Application Load Balancer
                       Public Subnets
                         HTTPS / 443
                               |
                               v
                    EC2 Auto Scaling Group
                     Private App Subnets
                       Nginx / Port 80
                         /          \
                        v            v
                  Amazon EFS     Amazon RDS
                   NFS / 2049    MySQL / 3306
                                 Private DB Subnets
```

The architecture spans three Availability Zones within a VPC.

### Networking

- Three public subnets for the Application Load Balancer.
- Three private application subnets for EC2 instances.
- Three isolated private database subnets for Amazon RDS.
- Internet Gateway for public subnet connectivity.
- One NAT Gateway for outbound connectivity from private application subnets.
- Separate route tables and security groups for infrastructure isolation.

The single NAT Gateway is a development-environment cost optimization and introduces a single point of failure.

## 3. AWS Services

| AWS Service | Purpose |
|---|---|
| Amazon VPC | Network isolation and subnet architecture |
| Amazon EC2 | Application compute instances |
| EC2 Auto Scaling | Application instance management and scaling capacity |
| Application Load Balancer | HTTPS entry point, traffic distribution, and health checks |
| Amazon CloudFront | Global content delivery and HTTPS access |
| Amazon Route 53 | DNS management |
| AWS Certificate Manager | TLS certificates |
| Amazon RDS | Managed MySQL database |
| Amazon EFS | Shared file storage |
| AWS IAM | Instance roles and least-privilege permissions |
| AWS Secrets Manager | RDS-managed database credentials |
| AWS Systems Manager | EC2 management capabilities |
| Amazon CloudWatch | Infrastructure metrics and alarms |
| Amazon SNS | Email-based monitoring notifications |

## 4. Terraform Repository Structure

```text
utc-app-terraform/
├── .gitignore
├── README.md
├── envs/
│   └── dev/
│       └── utc-app/
│           ├── iam.tf
│           ├── main.tf
│           ├── outputs.tf
│           └── variables.tf
└── modules/
    ├── alb/
    ├── cloudfront/
    ├── compute/
    ├── efs/
    ├── monitoring/
    ├── rds/
    ├── security_groups/
    └── vpc/
```

Each Terraform module manages a specific infrastructure component and exposes outputs for integration with other modules.

The root development environment connects these modules to create the complete infrastructure.

## 5. Security Architecture

Security controls include:

- Application instances deployed in private subnets.
- RDS deployed in isolated private database subnets without public accessibility.
- Security group rules restricting communication between infrastructure tiers.
- HTTPS for CloudFront viewer connections and ALB access.
- TLS-enabled EFS mounting.
- Encrypted EBS, EFS, and RDS storage.
- EC2 IAM roles instead of hardcoded AWS access keys.
- AWS-managed RDS master credentials stored in Secrets Manager.
- IAM policy restricting database-secret access to the designated secret.
- EC2 Instance Metadata Service Version 2 (IMDSv2).
- AWS Systems Manager permissions for EC2 administration.

**Development security consideration:** The public ALB can currently be reached independently of CloudFront. Restricting origin access is a future production-hardening improvement.

## 6. Application Compute

The application tier uses an EC2 Auto Scaling Group with an Amazon Linux 2023 launch template.

Configuration includes:

- EC2 instance type: `t3.micro`
- Desired capacity: 1
- Minimum capacity: 1
- Maximum capacity: 2
- Encrypted 20 GB gp3 root volume
- Nginx web server
- EFS mount configuration
- ALB health-check integration
- EC2 IAM instance profile

The EC2 bootstrap script installs Nginx and the EFS utilities, configures the EFS mount, creates a health-check endpoint, and starts the web server.

The initial application is a placeholder page displaying the UTC Student Services Portal environment.

## 7. Database and Storage

### Amazon RDS

- Database engine: MySQL 8.4
- Instance class: `db.t4g.micro`
- Storage: 20 GB gp3
- Storage encryption enabled
- Automated backups retained for 7 days
- Single-AZ configuration for the development environment
- Public accessibility disabled
- RDS-managed master password in AWS Secrets Manager

### Amazon EFS

- Encrypted shared file system
- General Purpose performance mode
- Elastic throughput mode
- Mount targets in private application subnets
- NFS access restricted to the application security group
- TLS-enabled mounting from EC2

## 8. Monitoring and Alerting

Amazon CloudWatch monitors infrastructure health and performance.

The current configuration defines three alarms:

| Alarm | Condition |
|---|---|
| ALB Unhealthy Targets | One or more unhealthy targets |
| ALB No Healthy Targets | Healthy target count below one |
| RDS High CPU | CPU utilization at or above 80% for five evaluation periods |

Alarm notifications are sent to an Amazon SNS topic with an email subscription.

The email subscription must be confirmed after deployment before notifications can be received.

## 9. Terraform Workflow

### Prerequisites

- Terraform CLI
- AWS CLI
- An AWS account with appropriate permissions
- Configured AWS credentials or an approved IAM identity
- An existing Route 53 hosted zone and appropriate ACM certificates

### Initialize Terraform

```bash
cd envs/dev/utc-app
terraform init
```

### Format the configuration

```bash
terraform fmt -recursive
```

### Validate the configuration

```bash
terraform validate
```

### Preview infrastructure changes

```bash
terraform plan
```

### Deploy infrastructure

Deployment is optional and may incur AWS charges.

```bash
terraform apply
```

Run deployment commands only after reviewing the plan, costs, permissions, and environment configuration.

### View infrastructure outputs

After deployment:

```bash
terraform output
```

Outputs include the portal URL, CloudFront distribution, ALB DNS name, Auto Scaling Group name, RDS endpoint, EFS file system ID, VPC ID, and monitoring SNS topic ARN.

## 10. Infrastructure Validation

The Terraform configuration has been reviewed for module integration, security group connectivity, IAM permissions, routing, and monitoring.

Latest confirmed Terraform plan:

```text
Plan: 61 to add, 0 to change, 0 to destroy.
```

Terraform validation completed successfully.

These checks validate the configuration and planned resources; they do not establish that the infrastructure has been successfully deployed or tested in AWS.

## 11. Development and Production Considerations

This project currently prioritizes hands-on learning, modular design, and development-environment cost control.

Future improvements include:

- Restricting ALB origin access to authorized CloudFront traffic.
- Adding automated Terraform validation and security scanning with GitHub Actions.
- Introducing more comprehensive CloudWatch monitoring and logging.
- Implementing the student services application and database integration.
- Evaluating Multi-AZ RDS and resilient NAT architecture for production.
- Adding automated application deployment.
- Improving credential rotation and operational procedures.
- Implementing infrastructure teardown and cost-management procedures.

## 12. Project Purpose

This project is part of a hands-on Cloud and DevOps engineering portfolio.

It demonstrates the design and management of AWS infrastructure using Terraform, with emphasis on:

**Infrastructure as Code | AWS Networking | Cloud Security | EC2 Auto Scaling | Managed Databases | Shared Storage | Monitoring | Modular Terraform Design**

---

**Project status:** Terraform configuration validated; deployment pending.

**Repository:** [utc-app-terraform](https://github.com/Rufneemkams4/utc-app-terraform)
