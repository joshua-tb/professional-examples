# IP Factory: Hybrid Connectivity

This IP Factory module assigns IP ranges and addresses for all required hybrid connectivity resources, such as Dedicated Interconnects, VLAN Attachments, VPN Tunnels, etc. 

Outputs are utilized by the calling module's configuration, but will require additional processing in parent module locals{} to be fully utilized in resource creation. 

## SCALE
This Factory is has the following scale:

- **Maximum** of FOUR Dedicated Interconnects 
- Dedicated Interconnects **must** be configured in pairs
- **Maximum** of FOUR Regions

## ASSUMPTIONS
This Factory assumes:

- TWO Remote Peer devices
- int0, int2 connect to Remote Peer A
- int1, int3 connect to Remote Peer B
- Remote Peers can map multiple VPN tunnels to a single, shared gateway






<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_DICS_LIST"></a> [DICS\_LIST](#input\_DICS\_LIST) | List of maps containing Dedicated Interconnect details. | `list(map(string))` | <pre>[<br>  {<br>    "DESCRIPTION": null,<br>    "NAME": null,<br>    "URL": null<br>  },<br>  {<br>    "DESCRIPTION": null,<br>    "NAME": null,<br>    "URL": null<br>  },<br>  {<br>    "DESCRIPTION": null,<br>    "NAME": null,<br>    "URL": null<br>  },<br>  {<br>    "DESCRIPTION": null,<br>    "NAME": null,<br>    "URL": null<br>  }<br>]</pre> | no |
| <a name="input_REGIONS"></a> [REGIONS](#input\_REGIONS) | Map of maps for each target region containing the region name and assigned ASN. | `map(map(string))` | n/a | yes |
| <a name="input_VPC_IP_RANGE"></a> [VPC\_IP\_RANGE](#input\_VPC\_IP\_RANGE) | Summarized CIDR range for the entire VPC. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_REMOTE_TUNNEL_INT_IPS"></a> [REMOTE\_TUNNEL\_INT\_IPS](#output\_REMOTE\_TUNNEL\_INT\_IPS) | n/a |
| <a name="output_TUNNEL_DICS_RANGES_INDEX"></a> [TUNNEL\_DICS\_RANGES\_INDEX](#output\_TUNNEL\_DICS\_RANGES\_INDEX) | n/a |
| <a name="output_TUNNEL_DICS_RANGES_MAP"></a> [TUNNEL\_DICS\_RANGES\_MAP](#output\_TUNNEL\_DICS\_RANGES\_MAP) | n/a |
| <a name="output_TUNNEL_INTS_ADDRS_REMOTE_ROUTERS"></a> [TUNNEL\_INTS\_ADDRS\_REMOTE\_ROUTERS](#output\_TUNNEL\_INTS\_ADDRS\_REMOTE\_ROUTERS) | n/a |
| <a name="output_TUNNEL_INTS_ADDRS_VPC_ROUTER"></a> [TUNNEL\_INTS\_ADDRS\_VPC\_ROUTER](#output\_TUNNEL\_INTS\_ADDRS\_VPC\_ROUTER) | n/a |
| <a name="output_TUNNEL_INTS_RANGES_INDEX"></a> [TUNNEL\_INTS\_RANGES\_INDEX](#output\_TUNNEL\_INTS\_RANGES\_INDEX) | n/a |
| <a name="output_TUNNEL_REGION_RANGES_INDEX"></a> [TUNNEL\_REGION\_RANGES\_INDEX](#output\_TUNNEL\_REGION\_RANGES\_INDEX) | n/a |
| <a name="output_TUNNEL_REGION_RANGES_MAP"></a> [TUNNEL\_REGION\_RANGES\_MAP](#output\_TUNNEL\_REGION\_RANGES\_MAP) | n/a |
| <a name="output_VA_DIC_RANGES_ASSIGNED"></a> [VA\_DIC\_RANGES\_ASSIGNED](#output\_VA\_DIC\_RANGES\_ASSIGNED) | n/a |
| <a name="output_VA_DIC_RANGES_INDEX"></a> [VA\_DIC\_RANGES\_INDEX](#output\_VA\_DIC\_RANGES\_INDEX) | n/a |
| <a name="output_VA_DIC_RANGES_MAP"></a> [VA\_DIC\_RANGES\_MAP](#output\_VA\_DIC\_RANGES\_MAP) | n/a |
| <a name="output_VA_REGION_RANGES_INDEX"></a> [VA\_REGION\_RANGES\_INDEX](#output\_VA\_REGION\_RANGES\_INDEX) | n/a |
| <a name="output_VA_REGION_RANGES_MAP"></a> [VA\_REGION\_RANGES\_MAP](#output\_VA\_REGION\_RANGES\_MAP) | n/a |
| <a name="output_VLAN_ID_INDEX"></a> [VLAN\_ID\_INDEX](#output\_VLAN\_ID\_INDEX) | n/a |
| <a name="output_VPC_ROUTER_TUNNEL_INT_IPS"></a> [VPC\_ROUTER\_TUNNEL\_INT\_IPS](#output\_VPC\_ROUTER\_TUNNEL\_INT\_IPS) | n/a |
| <a name="output_VPNGW_DIC_RANGES_ASSIGNED"></a> [VPNGW\_DIC\_RANGES\_ASSIGNED](#output\_VPNGW\_DIC\_RANGES\_ASSIGNED) | n/a |
| <a name="output_VPNGW_DIC_RANGES_INDEX"></a> [VPNGW\_DIC\_RANGES\_INDEX](#output\_VPNGW\_DIC\_RANGES\_INDEX) | n/a |
| <a name="output_VPNGW_DIC_RANGES_MAP"></a> [VPNGW\_DIC\_RANGES\_MAP](#output\_VPNGW\_DIC\_RANGES\_MAP) | n/a |
| <a name="output_VPNGW_INTS_REMOTE_ADDR"></a> [VPNGW\_INTS\_REMOTE\_ADDR](#output\_VPNGW\_INTS\_REMOTE\_ADDR) | n/a |
| <a name="output_VPNGW_REGION_RANGES_INDEX"></a> [VPNGW\_REGION\_RANGES\_INDEX](#output\_VPNGW\_REGION\_RANGES\_INDEX) | n/a |
| <a name="output_VPNGW_REGION_RANGES_MAP"></a> [VPNGW\_REGION\_RANGES\_MAP](#output\_VPNGW\_REGION\_RANGES\_MAP) | n/a |
<!-- END_TF_DOCS -->