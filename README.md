# Factory Module: `stratum-factory-gcp-vpc`

Provisions a GCP VPC network (custom-subnet mode) for the STRATUM platform.
Released as a git tag; consumed by the Wrapper via `source = "git::…?ref=v<semver>"`.

## Purpose

Creates a `google_compute_network` with `auto_create_subnetworks = false`
(custom-subnet mode). The VPC's `self_link` is passed to the subnet, firewall,
and DNS Factory modules by the Wrapper.

## Usage

```hcl
module "dev_vpc" {
  source = "git::https://github.com/apellini/stratum-factory-gcp-vpc.git?ref=v0.1.0"

  environment  = "dev"
  project_id   = "stratum-dev-sandbox"
  name_prefix  = "stratum-dev"
  routing_mode = "REGIONAL"
  tags         = { environment = "dev", managed_by = "opentofu" }
}
```

## Inputs

| Name | Type | Required | Validation | Description |
|------|------|----------|------------|-------------|
| `environment` | `string` | yes | one of `dev`, `stage`, `main` | Deployment environment |
| `project_id` | `string` | yes | non-empty, no whitespace | GCP project ID |
| `name_prefix` | `string` | yes | 3–24 chars, lowercase alphanumeric/hyphens, starts with letter | Resource name prefix |
| `tags` | `map(string)` | optional | all keys/values non-empty | Labels applied to all resources |
| `routing_mode` | `string` | optional (default: `REGIONAL`) | `REGIONAL` or `GLOBAL` | VPC routing mode |

## Outputs

| Name | Type | Description |
|------|------|-------------|
| `vpc_id` | `string` | Unique identifier of the VPC network |
| `vpc_name` | `string` | Name of the VPC (pass to firewall rules by name) |
| `vpc_self_link` | `string` | Self-link URI — pass to subnet, firewall, and DNS modules |

## Factory rules applied

- Stateless — no local state, no remote state reads
- Input-only — all configuration via `variables.tf`; nothing hardcoded
- Strict validation — every variable has a `validation` block
- No secrets — no sensitive values in code or outputs
- Documented for humans and RAG — this README + inline comments

## Release

Released as a git tag from this public Factory repo. The Wrapper consumes it as:

```hcl
source = "git::https://github.com/apellini/stratum-factory-gcp-vpc.git?ref=v0.1.0"
```
