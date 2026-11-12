# Azure Terraform Lab — Exact Granular Module Layout

This package refactors the current `terraform/Azure` lab into the **exact folder layout requested**.
The Azure deployment remains: Resource Group → VNet/Subnet/NSG → private Linux VM + NIC → Standard Load Balancer (public IP, backend pool, probe, rule, outbound rule).

## Layout

```text
terraform/Azure/
├── backend.tf                 # Existing Azure Blob backend (preserved)
├── providers.tf               # AzureRM provider (preserved)
├── variables.tf               # Existing root TF_VAR names (preserved)
├── outputs.tf                 # Existing output names (preserved)
├── main.tf                    # Root module composition only
└── modules/
    ├── resources/              # Resource Group
    │   ├── rg.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── network/
    │   ├── vnet/               # VNet
    │   │   ├── vnet.tf
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   ├── subnet/             # Subnet
    │   │   ├── subnet.tf
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   └── nsg/                 # NSG + NIC/NSG association
    │       ├── nsg.tf
    │       ├── variables.tf
    │       └── outputs.tf
    ├── compute/
    │   ├── vms/                 # Linux active; Windows optional template
    │   │   ├── linux.tf
    │   │   ├── windows.tf
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   ├── nics/                # Linux NIC active; Windows NIC optional
    │   │   ├── linux-nic.tf
    │   │   ├── win-nic.tf
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   └── storage/
    │       ├── os-disk.tf        # OS-disk settings object (not standalone Azure disk)
    │       ├── data-disks.tf     # Optional managed data disks
    │       ├── variables.tf
    │       └── outputs.tf
    └── load-balancer/
        ├── lb-pip.tf
        ├── lb.tf
        ├── lb-pool.tf
        ├── nic-pool-assoc.tf
        ├── lb-probes.tf
        ├── lb-rules.tf
        ├── variables.tf
        └── outputs.tf
```

## Important module design notes

- A folder is a Terraform module. Every `.tf` file in one module folder is loaded together.
- `modules/compute/vms` is one module containing `linux.tf` and `windows.tf`. Linux is enabled by default; Windows is opt-in (`create_windows_vm = true`) and requires Windows-specific inputs.
- `modules/compute/nics` is one module containing Linux and optional Windows NIC resources. Linux NIC is active; Windows NIC is opt-in.
- Azure VM OS disks are **nested VM configuration**, not a separate `azurerm_*_os_disk` resource. `os-disk.tf` therefore exports an OS disk settings object for the VM module. `data-disks.tf` creates actual managed disks and optional attachments.
- The existing root variable names (`location`, `resource_group_name`, `vm_name`, `vm_size`, `admin_username`, `admin_ssh_public_key`, `vnet_name`, `vnet_cidr`, `subnet_name`, `subnet_cidr`, `nsg_name`, `nic_name`, `load_balancer_name`, `load_balancer_public_ip_name`) are retained so existing GitHub Actions `TF_VAR_*` inputs continue to map.
- `backend.tf` is retained as-is. Do not run `terraform init -reconfigure` unless you intend to change the backend/state configuration.
- No cloud credentials or SSH private keys are included.

## Migration / run

1. Back up the current `terraform/Azure` directory and state.
2. Replace its `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`, and `backend.tf` with the package versions (backend/provider/variables retain the current values).
3. Copy `modules/` into `terraform/Azure/modules/`.
4. From `terraform/Azure` run:
   ```bash
   terraform fmt -recursive
   terraform init
   terraform validate
   terraform plan
   ```
5. Inspect the plan carefully. The refactor is intended to preserve resource addresses? **No**: moving resources under child modules changes addresses from `azurerm_*...` to `module.<name>.azurerm_*...`. Do not apply the plan as-is to an existing state. Use `terraform state mv` migration commands (provided in `STATE-MIGRATION.md`) or use `moved` blocks before applying.
6. Do not apply until the plan shows no unintended destroy/recreate.

## Learning order (strictly this hierarchy)

1. `modules/resources/rg.tf`
2. `modules/network/vnet/vnet.tf`
3. `modules/network/subnet/subnet.tf`
4. `modules/network/nsg/nsg.tf`
5. `modules/compute/nics/linux-nic.tf`
6. `modules/compute/storage/os-disk.tf`
7. `modules/compute/vms/linux.tf`
8. `modules/load-balancer/lb-pip.tf` → `lb.tf` → `lb-pool.tf` → `nic-pool-assoc.tf` → `lb-probes.tf` → `lb-rules.tf`
9. Trace each module output back into root `main.tf`, then inspect root `outputs.tf`.
