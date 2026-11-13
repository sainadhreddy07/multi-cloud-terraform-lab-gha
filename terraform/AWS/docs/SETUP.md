# AWS setup checklist
1. Bootstrap an S3 state bucket (versioning, encryption, public access block) and IAM GitHub OIDC role separately.
2. Trust policy should restrict `token.actions.githubusercontent.com` to this repository and branch/environment subject. GitHub environment changes the `sub`.
3. Add GitHub variables: `AWS_REGION`, `AWS_ROLE_ARN`, `AWS_AMI_ID` (region-specific Linux AMI).
4. `AMI_ID` is required as Terraform variable. The AMI must match region and CPU architecture.
5. Optional SSH: `AWS_KEY_NAME` and `AWS_ALLOWED_SSH_CIDR` as your public IP `/32`; omit CIDR to disable inbound SSH.
6. Configure backend.tf and initialize after bucket exists.
7. Run fmt/validate/plan; review public subnet, ALB and EC2 exposure/cost; then apply.
8. Test ALB URL and target health; destroy afterward. ALB incurs charges while running.
This sample uses EC2 in a public subnet with no SSH ingress by default; HTTP is via ALB SG. Hardened/private design should use SSM or a NAT path.
