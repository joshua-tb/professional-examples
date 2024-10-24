# Shared VPC

This module configures a "full service" VPC which contains a "Common" Subnet, Cloud Router, Cloud NAT, and Regional Proxy-Only Subnet for each target region. Cloud Routers are prepared for additional networking components, so an AS number must be provided for each region. 

This module configures:

- VPC
- Cloud Router
- "Common" subnet and IAM bindings
- Cloud NAT
- Google Private Services Access (for Services that use a Google-managed, VPC Peer network. ie 'servicenetworking')
- Explicit routes for restricted.googleapis.com and private.googleapis.com








<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_VPC_IP_FACTORY"></a> [VPC\_IP\_FACTORY](#module\_VPC\_IP\_FACTORY) | ../ip_factory/vpc_blocks | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.NAT_ADDRESS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_global_address.PRIVATE_SERVICES_RANGE](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network.VPC](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network_peering_routes_config.PRIVATE_SERVICES_ROUTES](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering_routes_config) | resource |
| [google_compute_route.PRIVATE_GOOGLEAPIS_COM](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_compute_route.RESTRICTED_GOOGLEAPIS_COM](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_compute_router.VPC_ROUTER](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.CLOUD_NAT](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.COMMON_SUBNET](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.REGIONAL_PROXY_ONLY_SUBNET](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork_iam_binding.IAM_BINDINGS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam_binding) | resource |
| [google_project_service.SERVICENETWORKING_API](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_networking_connection.PRIVATE_SERVICES](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_COMMON_SUBNET_REGION"></a> [COMMON\_SUBNET\_REGION](#input\_COMMON\_SUBNET\_REGION) | List of users allowed to use the subnet. Can be added upon request. | `string` | `""` | no |
| <a name="input_COMMON_SUBNET_USERS"></a> [COMMON\_SUBNET\_USERS](#input\_COMMON\_SUBNET\_USERS) | List of users allowed to use the subnet. Can be added upon request. | `list(string)` | `[]` | no |
| <a name="input_CREATE_COMMON_SUBNET"></a> [CREATE\_COMMON\_SUBNET](#input\_CREATE\_COMMON\_SUBNET) | If true, creates a 'common' subnet which can be used by service projects upon request. | `bool` | `true` | no |
| <a name="input_CUSTOM_ADVERTISED_ROUTES"></a> [CUSTOM\_ADVERTISED\_ROUTES](#input\_CUSTOM\_ADVERTISED\_ROUTES) | List of custom routes to be advertised to BGP neighbors, should be expressed WITH CIDR notation. | `list(string)` | `[]` | no |
| <a name="input_DESCRIPTION"></a> [DESCRIPTION](#input\_DESCRIPTION) | Description of the VPC. | `string` | n/a | yes |
| <a name="input_ENABLE_APIS"></a> [ENABLE\_APIS](#input\_ENABLE\_APIS) | Enables the activation of APIs or Services required for the module's resources. Set to 'false' to disable API activation. | `bool` | `true` | no |
| <a name="input_EXPORT_CUSTOM_ROUTES"></a> [EXPORT\_CUSTOM\_ROUTES](#input\_EXPORT\_CUSTOM\_ROUTES) | If True, exports any configured custom routes to the VPC Peer. | `bool` | `true` | no |
| <a name="input_HOST_PROJECT_ID"></a> [HOST\_PROJECT\_ID](#input\_HOST\_PROJECT\_ID) | Project ID for the Shared VPC Host Project. CONSIDER LINKING TO .id DATA RESOURCE ATTRIBUTE. | `string` | n/a | yes |
| <a name="input_IMPORT_CUSTOM_ROUTES"></a> [IMPORT\_CUSTOM\_ROUTES](#input\_IMPORT\_CUSTOM\_ROUTES) | If True, imports any configured custom routes into the Shared VPC route table. | `bool` | `false` | no |
| <a name="input_MTU_BYTES"></a> [MTU\_BYTES](#input\_MTU\_BYTES) | Size of the MTU (Maximum Transmission Unit) for the VPC in bytes. Should be 1500, or 8896. | `number` | `1500` | no |
| <a name="input_PRIVATE_SERVICES_IP_RANGE"></a> [PRIVATE\_SERVICES\_IP\_RANGE](#input\_PRIVATE\_SERVICES\_IP\_RANGE) | IP range assigned to Private Services Access. Should be a /16. CONSIDER LINKING TO vpc\_blocks IP FACTORY OUTPUT. | `string` | n/a | yes |
| <a name="input_REGIONS"></a> [REGIONS](#input\_REGIONS) | Map of objects for each target region containing the region name and assigned ASN. | `map(map(string))` | n/a | yes |
| <a name="input_VPC_IP_RANGE"></a> [VPC\_IP\_RANGE](#input\_VPC\_IP\_RANGE) | Summarized IP range assigned to the VPC. Should be a /14. | `string` | n/a | yes |
| <a name="input_VPC_NAME"></a> [VPC\_NAME](#input\_VPC\_NAME) | Name of the VPC to be created. CONSIDER LINKING TO .name DATA RESOURCE ATTRIBUTE. | `string` | n/a | yes |
| <a name="input_VPC_ROUTING_MODE"></a> [VPC\_ROUTING\_MODE](#input\_VPC\_ROUTING\_MODE) | Internal routing mode for the VPC. Can be either 'GLOBAL' or 'REGIONAL'. | `string` | `"REGIONAL"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_COMMON_SUBNET"></a> [COMMON\_SUBNET](#output\_COMMON\_SUBNET) | Full object for the COMMON SUBNETWORK. |
| <a name="output_REGIONAL_PROXY_ONLY_SUBNET"></a> [REGIONAL\_PROXY\_ONLY\_SUBNET](#output\_REGIONAL\_PROXY\_ONLY\_SUBNET) | List of full objects for the REGIONAL PROXY-ONLY SUBNETWORKS. |
| <a name="output_VPC"></a> [VPC](#output\_VPC) | Full VPC object. |
| <a name="output_VPC_ROUTERS"></a> [VPC\_ROUTERS](#output\_VPC\_ROUTERS) | List of full objects for the VPC ROUTERS. |
<!-- END_TF_DOCS -->