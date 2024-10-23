# 'Perimeter Bundle' Firewall Rules for Hybrid Environments

Contains a set of firewall rules restricting the VPC perimeter.

As this is designed for a Hybrid environment, all traffic to designated hybrid networks is allowed. All connectivity to on-premises networks will be evaluated and filtered by the on-premises security appliance. This allows for simpler firewall rule sets and ease of management.

Traffic to/from basic Google services (Private Google Access, Health Checks, etc.) is permitted by default. Load Balancer Backends can be tagged with 'lb-backend' to permit ingress traffic from the proxy-only network.

All intra-VPC traffic (for example: VPC_A/subnet01 -> VPC_A/subnet02 **AND** VPC_A/subnet01/vm01 -> VPC_A/subnet01/vm02) is denied unless explicitly permitted. All intra-VPC EGRESS traffic is 'allowed', but all intra-VPC INGRESS traffic is denied. This allows for all intra-VPC firewall exceptions to be created as `INGRESS` rules, further simplifying configuration and management while remaining secure.

More information on non-RFC1918 IP ranges being permitted:

**Health Checks**
https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges

**'Serverless' Supporting Infrastructure**
https://cloud.google.com/vpc/docs/configure-serverless-vpc-access#allow-ranges

**IAP TCP Forwarding for In-Browser SSH**
https://cloud.google.com/iap/docs/using-tcp-forwarding#create-firewall-rule

This bundle **allows**:
- ICMP
- INGRESS/EGRESS to provided HYBRID_RANGES
- Google health checks
- Private Google Access egress
- Designated proxy-only networks via tag 'lb-backend'
- Intra-VPC egress
- IAP TCP Forwarding ingress

This bundle **denies**:
- All traffic sourced from Serverless VPC Connectors
- Default ingress and egress deny





<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.ALLOW_HEALTHCHECKS_INGRESS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.ALLOW_HYBRID_EGRESS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.ALLOW_HYBRID_INGRESS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.ALLOW_ICMP_INGRESS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.ALLOW_INTRA_EGRESS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.ALLOW_PGA_EGRESS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.ALLOW_PROXYNET_INGRESS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.DENY_DEFAULT_EGRESS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.DENY_DEFAULT_INGRESS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.DENY_VPC_CONNECTORS_INGRESS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_HYBRID_RANGES"></a> [HYBRID\_RANGES](#input\_HYBRID\_RANGES) | A list of on-premises or otherwise hybrid IP ranges. | `list(string)` | n/a | yes |
| <a name="input_PROXY_NET_IP_RANGE"></a> [PROXY\_NET\_IP\_RANGE](#input\_PROXY\_NET\_IP\_RANGE) | IP range allocated for the load balancer proxy-only network. | `string` | n/a | yes |
| <a name="input_VPC_IP_RANGE"></a> [VPC\_IP\_RANGE](#input\_VPC\_IP\_RANGE) | Entire IP range reserved for the target VPC. | `string` | n/a | yes |
| <a name="input_VPC_NAME"></a> [VPC\_NAME](#input\_VPC\_NAME) | Name of the target VPC. CONSIDER LINKING TO .name DATA RESOURCE ATTRIBUTE. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->