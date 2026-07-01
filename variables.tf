# stratum-factory-gcp-vpc/variables.tf
#
# FACTORY pattern: all configuration received as input. NOTHING is hardcoded.
# Every variable carries a strict validation block.

variable "environment" {
  description = "Deployment environment. Must be one of the approved environment names."
  type        = string

  validation {
    condition     = contains(["dev", "stage", "main"], var.environment)
    error_message = "environment must be one of: dev, stage, main."
  }
}

variable "project_id" {
  description = "GCP project ID to deploy into. Must be non-empty with no whitespace."
  type        = string

  validation {
    condition     = length(var.project_id) > 0 && !can(regex("\\s", var.project_id))
    error_message = "project_id must be a non-empty string with no whitespace."
  }
}

variable "name_prefix" {
  description = "Prefix applied to all resource names. 3–24 lowercase alphanumeric or hyphens, starts with a letter."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,23}$", var.name_prefix))
    error_message = "name_prefix must be 3–24 chars, start with a letter, lowercase alphanumeric or hyphens only."
  }
}

variable "tags" {
  description = "Map of labels to apply to all resources. Keys and values must be non-empty strings."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : length(k) > 0 && length(v) > 0])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

variable "routing_mode" {
  description = "VPC routing mode. REGIONAL routes traffic within the region; GLOBAL routes across all regions."
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "routing_mode must be REGIONAL or GLOBAL."
  }
}

variable "mtu" {
  description = "Maximum Transmission Unit (MTU) for the VPC network in bytes. Valid range: 1300–8896. Default 1460 (standard Ethernet)."
  type        = number
  default     = 1460

  validation {
    condition     = var.mtu >= 1300 && var.mtu <= 8896
    error_message = "mtu must be between 1300 and 8896 (inclusive)."
  }
}

variable "delete_default_routes_on_create" {
  description = "When true, the default internet route (0.0.0.0/0 via default-internet-gateway) is deleted when the VPC is created. Useful for fully-controlled routing environments."
  type        = bool
  default     = false
}

variable "description" {
  description = "Human-readable description of the VPC network. When empty (the default), a standard STRATUM description is generated."
  type        = string
  default     = ""
}

variable "routes" {
  description = <<-EOT
    List of custom static routes to create in the VPC. Each entry maps to one google_compute_route resource.

    Attributes:
      name                   - (required) Route identifier appended to name_prefix. Lowercase letters, digits, hyphens; starts with a letter.
      dest_range             - (required) IPv4 CIDR destination range.
      priority               - (optional, default 1000) Route priority.
      description            - (optional, default "") Human-readable description.
      instance_tags          - (optional, default []) Network tags identifying VMs this route applies to.
      next_hop_gateway       - (optional) Self-link or "default-internet-gateway".
      next_hop_ip            - (optional) IP address of the next-hop instance within the VPC.
      next_hop_instance      - (optional) Self-link URL of a GCE instance.
      next_hop_instance_zone - (optional) Zone of next_hop_instance (required when next_hop_instance is set).
      next_hop_ilb           - (optional) Self-link of an internal load balancer forwarding rule.

    Exactly one of next_hop_gateway, next_hop_ip, next_hop_instance, or next_hop_ilb must be set per route.
    Default [] — no custom routes created when empty.
  EOT
  type = list(object({
    name                   = string
    dest_range             = string
    priority               = optional(number, 1000)
    description            = optional(string, "")
    instance_tags          = optional(list(string), [])
    next_hop_gateway       = optional(string)
    next_hop_ip            = optional(string)
    next_hop_instance      = optional(string)
    next_hop_instance_zone = optional(string)
    next_hop_ilb           = optional(string)
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.routes : can(regex("^[a-z][a-z0-9-]*$", r.name))])
    error_message = "Each route name must start with a lowercase letter and contain only lowercase letters, digits, or hyphens."
  }

  validation {
    condition = alltrue([
      for r in var.routes :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", r.dest_range))
    ])
    error_message = "Each route dest_range must be a valid IPv4 CIDR block (e.g. \"0.0.0.0/0\")."
  }

  validation {
    condition = alltrue([
      for r in var.routes :
      length([for v in [r.next_hop_gateway, r.next_hop_ip, r.next_hop_instance, r.next_hop_ilb] : v if v != null]) == 1
    ])
    error_message = "Each route must specify exactly one of: next_hop_gateway, next_hop_ip, next_hop_instance, or next_hop_ilb."
  }
}
