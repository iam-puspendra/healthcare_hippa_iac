hipaa-compliant-app/
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── kms/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── database/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── .github/workflows/deploy.yml
└── README.md

# HIPAA-Compliant AWS Architecture

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
