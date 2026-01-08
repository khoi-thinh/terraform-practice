# Terraform 2-Tier Architecture on AWS

This repository contains Terraform code to provision a **2-tier architecture on AWS**, following infrastructure-as-code best practices based on [original-repo](https://github.com/piyushsachdeva/10WeeksOfCloudOps_Task3) by @piyushsachdeva.

Modifications include:
- DynamoDB-based locking is deprecated, replaced with use_lockfile
- Removed `db_password` setup via variable; instead, `manage_master_user_password = true` is used for better security. The password can be checked from AWS Secret Manager.
- Changed EC2 and RDS instance types to `t3.micro` so it works in an AWS Free Tier account.

**🏗️ Architecture Overview**

The infrastructure includes the following components:

* **VPC:** Multi-AZ deployment with public and private subnets.
* **Application Load Balancer (ALB):** Positioned in public subnets to distribute incoming traffic.
* **EC2 Instances:** Located in **private subnets** to ensure they are not directly accessible from the internet.
* **NAT Gateway:** Provides outbound internet access for private instances (e.g., for software updates).
* **CloudFront:** Global Content Delivery Network (CDN) in front of the ALB for low latency and SSL termination.
* **Route 53:** Managed DNS service for custom domain mapping.
* **ACM:** AWS Certificate Manager for SSL/TLS certificates.

<img width="664" height="491" alt="image" src="https://github.com/user-attachments/assets/234e40a4-65a0-41d6-93b2-d009bff7e384" />

**Repository Structure**

```text
├── root/                # Root Terraform configuration
├── module/              # Reusable Terraform modules
│   ├── vpc/
│   ├── alb/
│   ├── ec2/
│   ├── cloudfront/
│   └── key/
└── README.md
```

**Prerequisites**

- Tested on v1.13.1
- AWS CLI configured with appropriate permissions
- An existing Route 53 hosted zone
- ACM certificate issued in us-east-1 (required for CloudFront)

**Usage**

```text
### 1. Generate a public-private key pair for EC2

cd modules/key/
ssh-keygen -t rsa -b 4096 -f ec2_key
This will generate:

ec2_key → private key (keep this secure)
ec2_key.pub → public key (used in Terraform for EC2 instances)

2. Create an S3 bucket for Terraform state and locking
Update /root/backend.tf with your bucket name.

3. Configure variables
Create root/terraform.tfvars with your project configuration:

region                  = "us-east-1"
project_name            = "2tierproject"
vpc_cidr                = "10.0.0.0/16"
pub_sub_1a_cidr         = "10.0.1.0/24"
pub_sub_2b_cidr         = "10.0.2.0/24"
pri_sub_3a_cidr         = "10.0.3.0/24"
pri_sub_4b_cidr         = "10.0.4.0/24"
pri_sub_5a_cidr         = "10.0.5.0/24"
pri_sub_6b_cidr         = "10.0.6.0/24"
db_username             = "admin"
certificate_domain_name = "khoidevops.space"
additional_domain_name  = "www.khoidevops.space"

4. Domain and ACM certificate
Make sure you have a domain managed in Route 53 (e.g., khoidevops.space).
Request an ACM certificate for your domain and any subdomains you plan to use:

aws acm request-certificate \
    --domain-name khoidevops.space \
    --subject-alternative-names www.khoidevops.space \
    --validation-method DNS \
    --region us-east-1

5. Initialize and apply Terraform
cd root
terraform init
terraform plan
terraform apply
```
