# AWS Nested Modules Lab (Phase 2 scaffold)
Status: **starter scaffold; not yet validated/deployed**.

## Architecture
GitHub Actions OIDC → Terraform → AWS:
VPC → public/private subnets (2 AZs) → IGW/routes → security groups → EC2 NGINX → internet-facing ALB → target group/HTTP listener.

## Prerequisites
- AWS account, region and permissions to bootstrap remote state and OIDC role.
- Terraform >= 1.5 (recommended current supported version).
- GitHub repository and IAM OIDC provider (`token.actions.githubusercontent.com`).
- Bootstrap S3 state bucket + IAM role before running the workload pipeline.
- Set GitHub Actions variables/secrets documented in `docs/SETUP.md`.

## Initial local validation
From `terraform/AWS`:
```bash
terraform fmt -recursive
terraform init -backend=false
terraform validate
```
Backend initialization and real plan require the state bucket and AWS role.

## Warning
This scaffold intentionally does not include account-specific role ARN, bucket, AMI ID, or credentials. Configure them; do not commit secrets. NAT Gateway is omitted to avoid surprise recurring cost. EC2 in public subnet is used in this starter to allow user_data package installation; restrict SSH and consider moving to private subnet with NAT/SSM for hardened design.
