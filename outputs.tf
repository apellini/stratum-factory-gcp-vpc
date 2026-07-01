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
