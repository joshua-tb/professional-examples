terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      #version = ">= 5.2.7"
    }
    #google-beta = {
    #  source = "hashicorp/google-beta"
    #}
  }
}

locals {
  REGION_INDEX = { for key, region in var.REGIONS :
  (region.IDX) => region.NAME }

  PROXY_ONLY_SUBNET_INDEX = [
    module.VPC_IP_FACTORY.INFRA_PROXY_ONLY_REGION_1,
    module.VPC_IP_FACTORY.INFRA_PROXY_ONLY_REGION_2,
    module.VPC_IP_FACTORY.INFRA_PROXY_ONLY_REGION_3,
    module.VPC_IP_FACTORY.INFRA_PROXY_ONLY_REGION_4
  ]
}

## IP Factory module
## NOT INCLUDED WITH PROFESSIONAL EXAMPLES
module "VPC_IP_FACTORY" {
  source = "../ip_factory/vpc_blocks"

  VPC_IP_RANGE = var.VPC_IP_RANGE
}

## API Activation

resource "google_project_service" "SERVICENETWORKING_API" {
  count = var.ENABLE_APIS ? 1 : 0

  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

## Resource creation

resource "google_compute_network" "VPC" {
  name                                      = var.VPC_NAME
  description                               = var.DESCRIPTION
  auto_create_subnetworks                   = false
  routing_mode                              = var.VPC_ROUTING_MODE
  mtu                                       = var.MTU_BYTES
  network_firewall_policy_enforcement_order = "BEFORE_CLASSIC_FIREWALL"
}

resource "google_compute_router" "VPC_ROUTER" {
  for_each = { for key, region in var.REGIONS :
  key => region }

  name    = "${var.VPC_NAME}-${each.value.NAME}-router"
  region  = each.value.NAME
  network = google_compute_network.VPC.self_link
  bgp {
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range       = var.VPC_IP_RANGE
      description = "Entire CIDR range assigned to ${var.VPC_NAME}."
    }
    dynamic "advertised_ip_ranges" {
      for_each = var.CUSTOM_ADVERTISED_ROUTES
      content {
        range       = advertised_ip_ranges.value
        description = "Custom route for ${advertised_ip_ranges.value}"
      }
    }
    asn                = each.value.ASN
    keepalive_interval = 60
  }
}

resource "google_compute_subnetwork" "COMMON_SUBNET" {
  count = var.CREATE_COMMON_SUBNET ? 1 : 0

  name                     = "${var.VPC_NAME}-${var.COMMON_SUBNET_REGION}-common"
  description              = "Common or shared subnet available to all users. Can be used for temporary internet connectivity, etc." #Should not be used as a permanent home for services. Can serve as DNS ingress ?
  ip_cidr_range            = cidrsubnet(var.VPC_IP_RANGE, "10", 1)
  network                  = google_compute_network.VPC.self_link
  region                   = var.COMMON_SUBNET_REGION == "" ? local.REGION_INDEX[0] : var.COMMON_SUBNET_REGION
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "REGIONAL_PROXY_ONLY_SUBNET" {
  for_each = { for key, region in var.REGIONS :
  key => region }

  name          = "${var.VPC_NAME}-${each.value.NAME}-proxy-only"
  description   = "'Proxy-Only' subnetwork used by load balancers to communicate with Backends.'"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  ip_cidr_range = local.PROXY_ONLY_SUBNET_INDEX[each.value.IDX]
  network       = google_compute_network.VPC.self_link
  region        = each.value.NAME
}

resource "google_compute_subnetwork_iam_binding" "IAM_BINDINGS" {
  count = var.CREATE_COMMON_SUBNET ? 1 : 0

  region     = google_compute_subnetwork.COMMON_SUBNET[count.index].region
  subnetwork = google_compute_subnetwork.COMMON_SUBNET[count.index].self_link
  role       = "roles/compute.networkUser"
  members    = var.COMMON_SUBNET_USERS
}

resource "google_compute_address" "NAT_ADDRESS" {
  for_each = google_compute_router.VPC_ROUTER

  name         = "${var.VPC_NAME}-${each.value.region}-nat-address"
  description  = ""
  region       = each.value.region
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}

resource "google_compute_router_nat" "CLOUD_NAT" {
  for_each = google_compute_address.NAT_ADDRESS

  name                               = "${var.VPC_NAME}-${each.value.region}-nat-general"
  router                             = google_compute_router.VPC_ROUTER[each.key].name
  region                             = each.value.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [each.value.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


##############################

# Configure Private Services Access

##############################

resource "google_compute_global_address" "PRIVATE_SERVICES_RANGE" {
  name          = "${var.VPC_NAME}-priv-svcs-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = trimsuffix(module.VPC_IP_FACTORY.PRIVATE_SERVICES_SUMMARY, "/16")
  prefix_length = 16
  network       = google_compute_network.VPC.id
}

resource "google_service_networking_connection" "PRIVATE_SERVICES" {
  network                 = google_compute_network.VPC.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.PRIVATE_SERVICES_RANGE.name]
}

resource "google_compute_network_peering_routes_config" "PRIVATE_SERVICES_ROUTES" {
  peering = google_service_networking_connection.PRIVATE_SERVICES.peering
  network = google_compute_network.VPC.name

  import_custom_routes = var.IMPORT_CUSTOM_ROUTES
  export_custom_routes = var.EXPORT_CUSTOM_ROUTES
}


##############################

# Add explicit static routes for private./restricted.googleapis.com
# See modules/dns/managed_zone for complete DNS configuration.
# Private Google Access will work with the basic default route,
# but having an explicit route will allow the default route to be changed
# without impact to 'internal' or 'private' traffic.

##############################

resource "google_compute_route" "RESTRICTED_GOOGLEAPIS_COM" {
  name             = "${var.VPC_NAME}-restricted-googleapis-com-route"
  network          = google_compute_network.VPC.self_link
  dest_range       = "199.36.153.4/30"
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
}

resource "google_compute_route" "PRIVATE_GOOGLEAPIS_COM" {
  name             = "${var.VPC_NAME}-private-googleapis-com-route"
  network          = google_compute_network.VPC.self_link
  dest_range       = "199.36.153.8/30"
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
}