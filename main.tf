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
  project                         = var.project_id
  name                            = "${var.name_prefix}-vpc"
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  mtu                             = var.mtu
  delete_default_routes_on_create = var.delete_default_routes_on_create

  description = var.description != "" ? var.description : "STRATUM ${var.environment} VPC — managed by OpenTofu (stratum-factory-gcp-vpc)"
}

# ── Custom static routes ──────────────────────────────────────────────────────
# Creates one google_compute_route per entry in var.routes.
# When routes is empty (the default), no route resources are created.
resource "google_compute_route" "custom" {
  for_each = { for r in var.routes : r.name => r }

  project          = var.project_id
  name             = "${var.name_prefix}-${each.value.name}"
  network          = google_compute_network.vpc.name
  dest_range       = each.value.dest_range
  priority         = each.value.priority
  description      = each.value.description
  tags             = length(each.value.instance_tags) > 0 ? each.value.instance_tags : null

  next_hop_gateway       = each.value.next_hop_gateway
  next_hop_ip            = each.value.next_hop_ip
  next_hop_instance      = each.value.next_hop_instance
  next_hop_instance_zone = each.value.next_hop_instance_zone
  next_hop_ilb           = each.value.next_hop_ilb
}
