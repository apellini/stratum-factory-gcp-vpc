# stratum-factory-gcp-vpc/main.tf
#
# FACTORY MODULE — GCP VPC (custom-subnet network).
#
# STATELESS & INPUT-ONLY:
#   - All configuration via variables.tf.
#   - No hardcoded values, no remote state reads, no secrets.
#   - State owned by the calling Wrapper.
#
# Consumed by the Wrapper as:
#   source = "git::https://github.com/apellini/stratum-factory-gcp-vpc.git?ref=v<semver>"

# ── VPC Network ───────────────────────────────────────────────────────────────
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode

  description = "STRATUM ${var.environment} VPC — managed by OpenTofu (stratum-factory-gcp-vpc)"
}
