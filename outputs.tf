# stratum-factory-gcp-vpc/outputs.tf
#
# FACTORY MODULE outputs — documented for humans and RAG.
# All outputs include type, purpose, and example value.

output "vpc_id" {
  description = <<-EOT
    Unique identifier of the VPC network.
    Type: string.
    Example: "projects/stratum-dev-sandbox/global/networks/stratum-dev-vpc"
  EOT
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = <<-EOT
    Name of the VPC network.
    Type: string. Example: "stratum-dev-vpc"
    Pass to downstream modules (subnet, firewall, dns) as the network name reference.
  EOT
  value       = google_compute_network.vpc.name
}

output "vpc_self_link" {
  description = <<-EOT
    Self-link URI of the VPC network.
    Type: string.
    Example: "https://www.googleapis.com/compute/v1/projects/stratum-dev-sandbox/global/networks/stratum-dev-vpc"
    Pass to the subnet, firewall, and DNS Factory modules via the Wrapper.
  EOT
  value       = google_compute_network.vpc.self_link
}

output "route_ids" {
  description = <<-EOT
    Map of custom route logical names to GCP resource IDs.
    Type: map(string).
    Example: { "to-internet" = "projects/stratum-dev-sandbox/global/routes/stratum-dev-to-internet" }
    Keys match the name attributes in the routes input variable. Empty map when routes = [].
  EOT
  value       = { for name, route in google_compute_route.custom : name => route.id }
}

output "route_names" {
  description = <<-EOT
    Map of custom route logical names to GCP resource names.
    Type: map(string).
    Example: { "to-internet" = "stratum-dev-to-internet" }
    Keys match the name attributes in the routes input variable. Empty map when routes = [].
  EOT
  value       = { for name, route in google_compute_route.custom : name => route.name }
}
