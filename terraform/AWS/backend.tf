# Configure S3 backend only after bootstrap bucket exists.
# Uncomment and fill values before terraform init.
# terraform {
#   backend "s3" {
#     bucket       = "REPLACE_WITH_STATE_BUCKET"
#     key          = "nested-modules/aws/terraform.tfstate"
#     region       = "REPLACE_WITH_BUCKET_REGION"
#     encrypt      = true
#     use_lockfile = true
#   }
# }
