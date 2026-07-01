# Factory Module: `stratum-factory-gcp-vpc`

Provisions a GCP VPC (custom-subnet) network for the STRATUM platform.

## Purpose

Creates a `google_compute_network` (custom-subnet mode) and optional `google_compute_route`
resources. MTU, routing mode, default-route deletion, and a custom description are all
configurable via input.

## Usage

```hcl
module "dev_vpc" {
  source = "git::https://github.com/apellini/stratum-factory-gcp-vpc.git?ref=v0.2.0"

  environment  = "dev"
  project_id   = "stratum-dev-sandbox"
  name_prefix  = "stratum-dev"
  routing_mode = "REGIONAL"
  mtu          = 1460
  tags         = { environment = "dev", managed_by = "opentofu" }

  # Optional: custom static routes
  routes = [
    {
      name             = "to-internet"
      dest_range       = "0.0.0.0/0"
      next_hop_gateway = "default-internet-gateway"
    },
  ]
}
```

## Inputs

| Name | Type | Required | Validation | Description |
|------|------|----------|------------|-------------|
| `environment` | `string` | yes | one of `dev`, `stage`, `main` | Deployment environment |
| `project_id` | `string` | yes | non-empty, no whitespace | GCP project ID |
| `name_prefix` | `string` | yes | 3–24 chars, lowercase alphanumeric/hyphens, starts with letter | Resource name prefix |
| `routing_mode` | `string` | optional (default `"REGIONAL"`) | `REGIONAL` or `GLOBAL` | VPC routing mode |
| `mtu` | `number` | optional (default `1460`) | 1300–8896 | Maximum Transmission Unit in bytes |
| `delete_default_routes_on_create` | `bool` | optional (default `false`) | — | Delete default internet route on create |
| `description` | `string` | optional (default `""`) | — | VPC description (auto-generated if empty) |
| `routes` | `list(object)` | optional (default `[]`) | see below | Custom static routes |
| `tags` | `map(string)` | optional (default `{}`) | all keys/values non-empty | Labels applied to all resources |

### `routes` object attributes

| Attribute | Type | Default | Validation | Description |
|-----------|------|---------|------------|-------------|
| `name` | `string` | — | lowercase letters/digits/hyphens, starts with letter | Route identifier (appended to `name_prefix`) |
| `dest_range` | `string` | — | valid IPv4 CIDR | Destination CIDR |
| `priority` | `number` | `1000` | — | Route priority |
| `description` | `string` | `""` | — | Human-readable description |
| `instance_tags` | `list(string)` | `[]` | — | Network tags restricting route applicability |
| `next_hop_gateway` | `string` | `null` | exactly one next_hop required | Gateway self-link or `"default-internet-gateway"` |
| `next_hop_ip` | `string` | `null` | exactly one next_hop required | Next-hop IP within the VPC |
| `next_hop_instance` | `string` | `null` | exactly one next_hop required | GCE instance self-link |
| `next_hop_instance_zone` | `string` | `null` | — | Zone of `next_hop_instance` |
| `next_hop_ilb` | `string` | `null` | exactly one next_hop required | ILB forwarding rule self-link |

## Outputs

| Name | Type | Description |
|------|------|-------------|
| `vpc_id` | `string` | Unique identifier of the VPC |
| `vpc_name` | `string` | Name of the VPC network |
| `vpc_self_link` | `string` | Self-link URI — pass to subnet, firewall, and DNS modules |
| `route_ids` | `map(string)` | Map of route logical names → GCP resource IDs |
| `route_names` | `map(string)` | Map of route logical names → GCP resource names |

## Factory rules applied

- **Stateless** — no local state, no remote state reads
- **Input-only** — all configuration via `variables.tf`; nothing hardcoded
- **Strict validation** — every variable has a `validation` block
- **No secrets** — no sensitive values in code or outputs
- **Documented for humans and RAG** — this README + inline comments

## Release

```hcl
source = "git::https://github.com/apellini/stratum-factory-gcp-vpc.git?ref=v0.2.0"
```
