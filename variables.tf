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
