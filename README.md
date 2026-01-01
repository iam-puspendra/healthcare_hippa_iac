## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        AWS Cloud (us-east-1)                    │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐ │
│  │   CloudFront    │    │  Route 53 DNS   │    │   CloudWatch    │ │
│  │   (HTTPS CDN)   │    │   (Optional)    │    │   (Logging)     │ │
│  │  d2r92y...      │    │                 │    │  90-day retention│ │
│  └─────────┬───────┘    └─────────────────┘    └─────────────────┘ │
│            │                                                   │
│  ┌─────────▼───────┐    ┌─────────────────┐    ┌─────────────────┐ │
│  │  Application    │    │   Secrets Mgr    │    │      KMS        │ │
│  │  Load Balancer  │◄──►│   (Credentials)  │◄──►│   (Encryption)  │ │
│  │  (ALB)          │    │                 │    │                 │ │
│  └─────────┬───────┘    └─────────────────┘    └─────────────────┘ │
│            │                                                   │
│  ┌─────────▼───────┐    ┌─────────────────┐    ┌─────────────────┐ │
│  │   ECS Fargate   │    │   DocumentDB     │    │   S3 Buckets    │ │
│  │  (Containers)   │◄──►│   (Database)     │◄──►│   (Storage)     │ │
│  │  Frontend/Backend│    │   Encrypted     │    │   Encrypted     │ │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

# Project Structure

```
healthcare/
├── main.tf                 # Root configuration
├── variables.tf            # Input variables
├── terraform.tfvars        # Variable values
├── modules/
│   ├── vpc/               # Network infrastructure
│   ├── compute/           # ECS and ALB
│   ├── database/          # DocumentDB cluster
│   ├── iam/               # Roles and policies
│   ├── secrets/           # Secrets Manager
│   ├── s3/                # S3 buckets
│   └── cloudfront/        # CDN distribution
└── README.md              # This file
```

## How to Initialize

1. Set up remote state with S3 backend and DynamoDB for locking.
2. Sign the AWS Business Associate Addendum (BAA) via AWS Artifact.
3. Ensure all PHI is encrypted at rest and in transit.
4. Run compliance checks and update documentation for audits.

## Usage

- Initialize Terraform: `terraform init`
- Plan deployment: `terraform plan`
- Apply changes: `terraform apply`

## Security

- No PHI in logs or tags.
- All data encrypted with KMS CMKs.
- Network isolation via VPC tiers.
- Least-privilege IAM roles.

## CI/CD

- GitHub Actions workflow for OIDC authentication, plan, and apply.
