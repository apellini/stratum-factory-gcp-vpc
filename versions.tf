# stratum-factory-gcp-vpc/versions.tf
# OpenTofu and provider version pins. Run `tofu init` to populate .terraform.lock.hcl.
# See: docs/blueprints/opentofu-module-rules.md §3.1

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}
