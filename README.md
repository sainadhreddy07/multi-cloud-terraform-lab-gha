# Multi-Cloud Terraform Lab with GitHub Actions

A three-stack learning lab that deploys equivalent web-backend and HTTP load-balancing patterns to Azure, AWS, and Google Cloud using one independent GitHub Actions workflow per provider.

## Tool and provider versions

The scaffold pins Terraform CLI to `1.17.1`, AzureRM to `5.4.0`, AWS to `6.71.0`, and Google to `8.7.0`. These were checked against the official HashiCorp Terraform Registry on 7 November 2026. The exact provider pins reduce unplanned version drift; update them deliberately when maintaining the lab.

## Deployment behaviour

- Start a provider workflow manually from **Actions** (`workflow_dispatch`).
- Select `deploy`: the workflow runs `fmt`, `init`, `validate`, and `plan`; **a successful plan is followed immediately by `terraform apply -auto-approve`**. There is no environment approval gate.
- Select `destroy` only when intentionally removing that provider's stack. The workflow creates a destroy plan and applies it automatically.
- The workflows are independent. Running Azure does not run AWS or GCP.
- A normal `git push` does not deploy infrastructure. This is intentional for a cost-bearing lab; deployment is started explicitly from Actions.

## Repository layout

```text
multi-cloud-terraform-lab-gha/
├── terraform/
│   ├── Azure/  # Standard public Load Balancer + one Linux VM
│   ├── AWS/    # Internet-facing Application Load Balancer + one EC2 instance
│   └── GCP/    # Global external Application Load Balancer + one Compute Engine VM
├── .github/workflows/
│   ├── azure-deployment.yml
│   ├── aws-deployment.yml
│   └── gcp-deployment.yml
├── .gitignore
└── README.md
```

## Resource mapping

| Concept | Azure | AWS | GCP |
|---|---|---|---|
| Virtual network | VNet | VPC | VPC network |
| Subnet | Subnet | Public subnets in two AZs | Subnetwork |
| VM | Linux Virtual Machine | EC2 instance | Compute Engine instance |
| NIC | Network Interface | Elastic Network Interface | VM `network_interface` block (part of the VM resource) |
| VM public IP | Not assigned; LB frontend is public | Elastic IP attached to the EC2 ENI | Ephemeral external IP on the VM NIC |
| Public load-balancer IP/front end | Standard Public IP + LB frontend IP configuration | Internet-facing ALB DNS name (AWS manages its frontend addresses) | Reserved global external IPv4 address + forwarding rule |
| Backend pool | LB backend address pool | Target group | Instance group backend |
| Health probe | LB probe | Target-group health check | Compute health check |
| Listener/rule | LB rule | ALB listener | Target HTTP proxy + URL map + forwarding rule |
| Network security | NSG | Security Groups | VPC firewall rule |

**Important provider differences:** GCP does not have an Azure NSG resource or an AWS ENI resource that is managed independently in this design. The VM NIC is configured inside `google_compute_instance`. On AWS, the Application Load Balancer exposes a DNS name rather than a customer-reserved single static frontend IP. The requested public IP resource is also represented by an Elastic IP attached to the EC2 ENI.

Each stack has one backend VM. That is enough to validate frontend reachability and health checks, but it does not demonstrate multi-instance traffic distribution or backend failover.

## Existing remote state — reused, not recreated

The workflows expect the existing remote state services to remain in place. They write to new, dedicated state paths so this repository does not overwrite state from your previous labs:

| Provider | Existing state service | New state path |
|---|---|---|
| Azure | Existing Storage Account and container | The `AZURE_TFSTATE_KEY` variable (use `multi-cloud-terraform-lab-gha/azure.tfstate`) |
| AWS | Existing S3 bucket | The `AWS_TFSTATE_KEY` variable (use `multi-cloud-terraform-lab-gha/aws/terraform.tfstate`) |
| GCP | Existing GCS bucket | The `GCP_TFSTATE_PREFIX` variable (use `multi-cloud-terraform-lab-gha/gcp`) |

Do not delete, rename, or replace the existing buckets, containers, or storage accounts. Do not reuse the previous lab's state key/prefix. The state services must already exist before the workflow runs.

The AWS backend uses S3 native state locking (`use_lockfile = true`), which requires Terraform 1.10 or later. Enable S3 bucket versioning for recovery. The Azure backend uses Microsoft Entra ID/OIDC data-plane authentication; no SAS token or storage account key is used by this workflow. The GCS backend uses the authenticated Google Cloud identity and backend object preconditions for locking.

## Before creating the GitHub repository

1. Create an **empty** GitHub repository named `multi-cloud-terraform-lab-gha`. Do not initialize it with a README, `.gitignore`, or license; this local scaffold already contains those files.
2. Keep the default branch as `main`.
3. Extract this ZIP, open a terminal in the extracted `multi-cloud-terraform-lab-gha` folder, and initialize/push the local repository:

   ```bash
   git init -b main
   git add .
   git commit -m "Initialize multi-cloud Terraform lab with GitHub Actions"
   git remote add origin https://github.com/sainadhreddy07/multi-cloud-terraform-lab-gha.git
   git push -u origin main
   ```

   Change the GitHub owner in the remote URL if the repository is created under a different account or organization.
4. In **Settings → Actions → General**, allow GitHub Actions for the repository. The workflows need OIDC: `id-token: write` is already declared in each workflow, but the cloud-side federation must also be configured.
5. Add the variables and secrets listed below under **Settings → Secrets and variables → Actions**.
6. Configure OIDC federation in Azure, AWS, and GCP after you know the new repository's immutable GitHub owner ID and repository ID (see the OIDC section). Do not copy the old repository's federation subject from a previous lab.

## GitHub repository variables and secrets

Set these as **Repository variables** unless the row is explicitly marked Secret. The workflows map them into `TF_VAR_*` environment variables. `variables.tf` deliberately contains declarations only—there are no defaults or environment-specific values in it.

### Azure

**Secrets**

| Secret | Value |
|---|---|
| `AZURE_CLIENT_ID` | Client ID of the Entra application / user-assigned managed identity used for GitHub OIDC |
| `AZURE_TENANT_ID` | Microsoft Entra tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Target Azure subscription ID |
| `AZURE_SSH_PUBLIC_KEY` | One-line OpenSSH public key, e.g. the contents of `id_ed25519.pub` (never upload the private key) |

**Variables**

| Variable | Meaning |
|---|---|
| `AZURE_LOCATION` | Azure region |
| `AZURE_RESOURCE_GROUP_NAME` | Resource group for this stack |
| `AZURE_VM_NAME` | Linux VM name |
| `AZURE_VM_SIZE` | VM SKU verified as available in the selected region/subscription |
| `AZURE_ADMIN_USERNAME` | Linux admin username |
| `AZURE_VNET_NAME` | VNet name |
| `AZURE_VNET_CIDR` | Example: `10.20.0.0/16` |
| `AZURE_SUBNET_NAME` | Subnet name |
| `AZURE_SUBNET_CIDR` | Example: `10.20.1.0/24` |
| `AZURE_NSG_NAME` | NSG name |
| `AZURE_NIC_NAME` | VM NIC name |
| `AZURE_LB_NAME` | Standard Load Balancer name |
| `AZURE_LB_PUBLIC_IP_NAME` | Public IP resource name for the LB frontend |
| `AZURE_TFSTATE_RESOURCE_GROUP` | Existing resource group containing the state Storage Account |
| `AZURE_TFSTATE_STORAGE_ACCOUNT` | Existing Storage Account name |
| `AZURE_TFSTATE_CONTAINER` | Existing container name |
| `AZURE_TFSTATE_KEY` | New state blob key, e.g. `multi-cloud-terraform-lab-gha/azure.tfstate` |

**Azure role assignments and federated credential**

- Create/configure a Microsoft Entra application or user-assigned managed identity with a federated credential for this repository and `main` branch.
- For a repository created after 15 July 2026, GitHub's default OIDC subject is immutable and has the form `repo:OWNER@OWNER_ID/REPO@REPO_ID:ref:refs/heads/main`. Use the exact subject shown by GitHub's OIDC reference for the newly created repository.
- This stack creates its resource group, so the straightforward lab setup requires `Contributor` at the selected subscription scope (or an equivalent custom role that can create the resource group and manage its resources). A stricter alternative is to pre-create and look up the resource group rather than create it in this stack. Grant `Storage Blob Data Contributor` on the existing state container or Storage Account. The backend is configured for Entra ID data-plane auth, not storage keys/SAS.
- The Storage Account must permit the GitHub runner to reach its data plane. If it is network-restricted, configure an approved network path; an RBAC role alone does not bypass storage firewall rules.

### AWS

**Secret**

| Secret | Value |
|---|---|
| `AWS_ROLE_TO_ASSUME` | IAM role ARN trusted for this repository's GitHub OIDC identity |

**Variables**

| Variable | Meaning |
|---|---|
| `AWS_REGION` | Region for the VPC, EC2, ALB and S3 state backend |
| `AWS_PROJECT_NAME` | Short resource-name/tag prefix |
| `AWS_VPC_CIDR` | VPC CIDR, e.g. `10.30.0.0/16` |
| `AWS_PUBLIC_SUBNET_1_CIDR` | First public subnet CIDR, e.g. `10.30.1.0/24` |
| `AWS_PUBLIC_SUBNET_2_CIDR` | Second public subnet CIDR, e.g. `10.30.2.0/24` |
| `AWS_INSTANCE_TYPE` | x86_64 EC2 instance type confirmed in the selected region/account; the AMI lookup is explicitly for x86_64 |
| `AWS_INSTANCE_NAME` | EC2 Name tag |
| `AWS_ALB_NAME` | ALB name (maximum 32 characters; use lowercase letters, numbers and hyphens) |
| `AWS_TARGET_GROUP_NAME` | Target group name (maximum 32 characters; use letters, numbers and hyphens) |
| `AWS_ALLOWED_HTTP_CIDR` | Allowed ALB client source CIDR; `0.0.0.0/0` opens the HTTP listener to the internet |
| `AWS_TFSTATE_BUCKET` | Existing S3 state bucket |
| `AWS_TFSTATE_KEY` | New state key, e.g. `multi-cloud-terraform-lab-gha/aws/terraform.tfstate` |

**AWS OIDC trust and permissions**

- Add the GitHub OIDC identity provider `https://token.actions.githubusercontent.com` with audience `sts.amazonaws.com` if it is not already present in the account.
- Create an IAM role whose trust policy matches the new repository's immutable `sub` exactly. Its subject format is `repo:OWNER@OWNER_ID/REPO@REPO_ID:ref:refs/heads/main` for repositories created after 15 July 2026. The audience condition must equal `sts.amazonaws.com`.
- Grant the role permissions for the EC2/VPC/Elastic Load Balancing resources in this lab, `ssm:GetParameter` for the public Amazon Linux 2023 AMI parameter, and read/write/delete access to the specific S3 state key plus the `.tflock` object. The role also needs S3 bucket listing on the state bucket. If the account has never used ELB, pre-create the ELB service-linked role or grant the narrowly required `iam:CreateServiceLinkedRole` permission.
- Enable bucket versioning. S3 native state locking requires permissions on the lock object as well as the state object.

**Application Load Balancer and Free Tier**

AWS documentation currently describes an ALB Free Tier offer for eligible new accounts: 750 ALB hours and 15 LCUs for 12 months. New accounts created from 15 July 2025 are also covered by the newer Free Tier credit/plan model. This does not mean every existing AWS account is eligible. Check the account's Free Tier page and current billing terms before deploying. ALBs incur hourly and LCU usage charges when not covered by an applicable offer. The lab uses an internet-facing ALB across two public subnets in two availability zones, as required by the service. The EC2 VM has an Elastic IP to satisfy the VM public-IP portion of the exercise; the instance Security Group accepts HTTP only from the ALB Security Group.

### GCP

**Repository variables** (no service-account JSON key is required)

| Variable | Meaning |
|---|---|
| `GCP_PROJECT_ID` | Existing GCP project ID |
| `GCP_REGION` | Region for the subnet |
| `GCP_ZONE` | Zone for the VM and unmanaged instance group; must be inside the selected region |
| `GCP_VM_NAME` | Compute Engine VM name |
| `GCP_MACHINE_TYPE` | Machine type available in the selected zone |
| `GCP_VPC_NAME` | VPC network name |
| `GCP_SUBNET_NAME` | Subnetwork name |
| `GCP_SUBNET_CIDR` | Subnet CIDR, e.g. `10.40.1.0/24` |
| `GCP_FIREWALL_NAME` | VPC firewall rule name |
| `GCP_LB_NAME` | Prefix for the global external Application Load Balancer resources |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | Full provider resource name: `projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/providers/PROVIDER_ID` |
| `GCP_TERRAFORM_SERVICE_ACCOUNT` | Service account email impersonated by GitHub Actions |
| `GCP_TFSTATE_BUCKET` | Existing GCS state bucket |
| `GCP_TFSTATE_PREFIX` | New prefix, e.g. `multi-cloud-terraform-lab-gha/gcp` |

**GCP WIF and IAM**

- Enable the required APIs in the project, including Compute Engine and IAM Credentials / Security Token Service as needed for the WIF setup.
- Configure the Workload Identity Provider to accept GitHub's OIDC issuer and restrict its attribute condition to this repository. Also map `assertion.repository_id` and restrict the provider condition to the exact repository ID.
- Grant the service account `roles/iam.workloadIdentityUser` to the matching `principalSet` for this repository ID.
- Grant the service account `roles/compute.admin` for this lab and `roles/storage.objectAdmin` on the existing state bucket. If the deployment identity needs to act as a Compute Engine service account, grant the appropriate `roles/iam.serviceAccountUser` scope.
- Use WIF; do not create or store a long-lived service-account JSON key.

## Immutable GitHub OIDC subjects — new-repository precaution

GitHub changed the default OIDC `sub` for repositories created after **15 July 2026**. New repositories include immutable owner and repository IDs. Do not use the old form `repo:OWNER/REPO:ref:refs/heads/main` for this new repository.

After creating the empty remote repository, retrieve its metadata from `https://api.github.com/repos/OWNER/multi-cloud-terraform-lab-gha` (or the repository's GitHub API page) and note:

- `owner.id` — GitHub owner ID
- `id` — repository ID

Then use this exact `sub` format for Azure federated credentials and AWS IAM trust:

```text
repo:OWNER@OWNER_ID/multi-cloud-terraform-lab-gha@REPO_ID:ref:refs/heads/main
```

For GCP, map the immutable subject and repository identifier claims, then enforce the exact `repository` and `repository_id` in the provider attribute condition. This avoids relying only on a mutable repository name.

## Pre-run checks

- Confirm all GitHub variables and secrets are populated. An empty GitHub variable becomes an empty `TF_VAR_*` value and will fail Terraform validation or resource creation.
- Confirm the existing backend bucket/container and key path. Backend resources are **not** created by these stacks.
- Confirm OIDC trust conditions point to the new repository, `main` branch, and the new immutable subject.
- Confirm cloud roles have backend state permissions as well as infrastructure permissions. This avoids the earlier state-backend authorization failures (for example, Azure Blob `403 AuthorizationPermissionMismatch`).
- Confirm VM size / machine type / instance type availability in the selected region or zone. Provider authentication does not imply SKU availability.
- For Azure, check VM SKU availability before dispatch; do not assume a size is offered in every region or subscription. This specifically avoids repeating the earlier `SkuNotAvailable` error. With Azure CLI installed and logged into the target subscription, run `az vm list-skus --location "$AZURE_LOCATION" --resource-type virtualMachines --all --output table`; choose a SKU with no applicable location, zone, or subscription restriction.
- For AWS, ensure the selected region has at least two available AZs and that the two subnet CIDRs are non-overlapping and inside the VPC CIDR.
- For GCP, confirm the Compute Engine API is enabled and the selected zone belongs to the selected region. Allow several minutes for WIF provider and IAM changes to propagate.
- Ensure the GitHub Actions workflow is run from `main`. Cloud trust is intentionally restricted to that branch.
- Review the generated plan in the workflow log. The next step applies that exact saved plan automatically when plan succeeds.
- Check estimated/current cloud charges before starting. Load balancers, public IPv4 addresses, VMs, disks and data transfer can incur charges.

## Running the lab

1. Push the local repository to GitHub's `main` branch.
2. Open **Actions**.
3. Select `Azure Terraform Deployment`, `AWS Terraform Deployment`, or `GCP Terraform Deployment`.
4. Select **Run workflow** on branch `main`; leave operation as `deploy`.
5. Watch the `fmt → init → validate → plan → apply` sequence. If plan fails, apply is skipped automatically.
6. Read the Terraform outputs in the run log and open the relevant load-balancer URL.
7. When finished, run the same provider workflow with operation `destroy`.

## Local setup

Before the first push, run a local syntax and provider-schema check from the repository root. This does not touch the existing remote state services:

```bash
terraform fmt -recursive
terraform -chdir=terraform/Azure init -backend=false
terraform -chdir=terraform/Azure validate
terraform -chdir=terraform/AWS init -backend=false
terraform -chdir=terraform/AWS validate
terraform -chdir=terraform/GCP init -backend=false
terraform -chdir=terraform/GCP validate
```

Commit the generated `.terraform.lock.hcl` file from each provider folder. For a Windows development machine with GitHub's Linux runner, generate checksums for both platforms in each folder, for example:

```bash
terraform -chdir=terraform/Azure providers lock -platform=windows_amd64 -platform=linux_amd64
terraform -chdir=terraform/AWS providers lock -platform=windows_amd64 -platform=linux_amd64
terraform -chdir=terraform/GCP providers lock -platform=windows_amd64 -platform=linux_amd64
```

For an actual local plan, configure that provider's credentials and supply the same `TF_VAR_*` variables as the workflow. The `backend.tf` files are partial backend configurations; pass the matching `-backend-config` values during `terraform init` as the workflows do. Do not commit local `.tfvars` or credential files.

Example Azure backend initialization and plan (after setting local environment variables and backend values):

```bash
cd terraform/Azure
terraform fmt -recursive
terraform init -reconfigure \
  -backend-config="resource_group_name=$AZURE_TFSTATE_RESOURCE_GROUP" \
  -backend-config="storage_account_name=$AZURE_TFSTATE_STORAGE_ACCOUNT" \
  -backend-config="container_name=$AZURE_TFSTATE_CONTAINER" \
  -backend-config="key=$AZURE_TFSTATE_KEY"
terraform validate
terraform plan
```

The AWS and GCP workflows show the corresponding backend configuration arguments. Keep the provider-specific state paths separate.

## Known design boundaries

- These are three independent root modules, not one multi-cloud Terraform state. Each workflow has its own backend and lock.
- There is one VM backend per cloud; the design demonstrates an LB listener, backend registration and health probe, not scale-out or HA across multiple VM backends.
- The lab uses HTTP on port 80 only. It does not configure TLS certificates, HTTPS listeners, DNS names, Bastion, NAT Gateway, or private-only administration.
- AWS ALB front-end addresses are AWS-managed; use the ALB DNS name as the stable application endpoint. The separate EC2 Elastic IP is not the ALB frontend IP.
- GCP's firewall rule is the functional network-security equivalent; there is no GCP resource named NSG.
- The GitHub Actions workflows are intentionally manually dispatched. Once a `deploy` run starts, the successful Terraform plan automatically applies without a separate approval.

## Official references

- [GitHub OIDC reference and immutable subject claims](https://docs.github.com/en/actions/reference/security/oidc)
- [GitHub OIDC with Azure](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure)
- [GitHub OIDC with AWS](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws)
- [Google Cloud Workload Identity Federation for deployment pipelines](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines)
- [AzureRM backend authentication](https://developer.hashicorp.com/terraform/language/backend/azurerm)
- [AWS S3 backend and native locking](https://developer.hashicorp.com/terraform/language/backend/s3)
- [Azure Standard Load Balancer Terraform resources](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb)
- [Azure Load Balancer outbound rule Terraform resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_outbound_rule)
- [AWS Application Load Balancer pricing](https://aws.amazon.com/elasticloadbalancing/pricing/)
- [AWS Elastic Load Balancing FAQ and ALB Free Tier](https://aws.amazon.com/elasticloadbalancing/faqs/)
- [Google Cloud external Application Load Balancer](https://cloud.google.com/load-balancing/docs/https)
