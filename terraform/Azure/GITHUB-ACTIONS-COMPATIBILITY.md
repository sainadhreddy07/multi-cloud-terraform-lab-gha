# GitHub Actions compatibility

- Keep the workflow's Terraform working directory at `terraform/Azure`.
- Existing `TF_VAR_*` names are retained. For example, `TF_VAR_resource_group_name` still maps to root `variable "resource_group_name"`.
- Backend configuration remains the same (Azure Blob key and auth behavior preserved).
- Child-module inputs are wired from root variables and module outputs; the workflow does not need to know child-module variable names.
- Optional Windows values are not required unless `TF_VAR_create_windows_vm=true`. To enable Windows, provide a secure `TF_VAR_windows_admin_password` secret.
- Optional data disks are off by default (`data_disk_count=0`).
