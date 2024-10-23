terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

# ALLOW ICMP
resource "google_compute_firewall" "ALLOW_ICMP_INGRESS" {
  name        = "allow-icmp-ingress-${var.VPC_NAME}"
  network     = var.VPC_NAME
  description = "Permits INGRESS ICMP traffic from RFC1918 IP ranges"
  direction   = "INGRESS"
  priority    = 4000

  source_ranges      = ["10.0.0.0/8"]
  destination_ranges = [var.VPC_IP_RANGE]

  allow {
    protocol = "icmp"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "ALLOW_ICMP_EGRESS" {
  name        = "allow-icmp-egress-${var.VPC_NAME}"
  network     = var.VPC_NAME
  description = "Permits EGRESS ICMP traffic from RFC1918 IP ranges."
  direction   = "EGRESS"
  priority    = 4000

  source_ranges      = ["10.0.0.0/8"]
  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# ALLOW ALL INGRESS AND EGRESS TRAFFIC TO DESIGNATED HYBRID RANGES (TO BE FILTERED / EVALUATED WITH HYBRID APPLIANCE)
resource "google_compute_firewall" "ALLOW_HYBRID_EGRESS" {
  count = var.CREATE_HYBRID_RULES ? 1 : 0

  name        = "allow-hybrid-ranges-egress-${var.VPC_NAME}"
  network     = var.VPC_NAME
  description = "Permits EGRESS traffic to specified hybrid CIDR ranges."
  direction   = "EGRESS"
  priority    = 4010

  source_ranges      = ["0.0.0.0/0"]
  destination_ranges = var.HYBRID_RANGES

  allow {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  lifecycle {
    precondition {
      condition     = length(var.HYBRID_RANGES) != 0
      error_message = "Error: var.CREATE_HYBRID_RANGES is set to 'true', but no hybrid network ranges have been provided. Please update var.HYBRID_RANGES with at least one hybrid IP range."
    }
  }
}

resource "google_compute_firewall" "ALLOW_HYBRID_INGRESS" {
  count = var.CREATE_HYBRID_RULES ? 1 : 0

  name        = "allow-hybrid-ranges-ingress-${var.VPC_NAME}"
  network     = var.VPC_NAME
  description = "Permits INGRESS traffic from specified hybrid CIDR ranges."
  direction   = "INGRESS"
  priority    = 4010

  source_ranges      = var.HYBRID_RANGES
  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  lifecycle {
    precondition {
      condition     = length(var.HYBRID_RANGES) != 0
      error_message = "Error: var.CREATE_HYBRID_RANGES is set to 'true', but no hybrid network ranges have been provided. Please update var.HYBRID_RANGES with at least one hybrid IP range."
    }
  }
}

# ALLOW GOOGLE HEALTH CHECKS INGRESS
# MORE INFO ON THIS HERE:
# https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
resource "google_compute_firewall" "ALLOW_HEALTHCHECKS_INGRESS" {
  name        = "allow-healthchecks-ingress-${var.VPC_NAME}"
  network     = var.VPC_NAME
  description = "Permits INGRESS traffic from specified hybrid CIDR ranges."
  direction   = "INGRESS"
  priority    = 4020

  source_ranges      = ["35.191.0.0/16", "130.211.0.0/22"]
  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }

  # UNCOMMENT TO ENABLE LOGGING. GENERALLY NOT REQUIRED.
  #log_config {
  #  metadata = "EXCLUDE_ALL_METADATA"
  #}
}

# ALLOW PRIVATE GOOGLE ACCESS EGRESS
resource "google_compute_firewall" "ALLOW_PGA_EGRESS" {
  name        = "allow-pga-egress-${var.VPC_NAME}"
  network     = var.VPC_NAME
  description = "Permits EGRESS traffic to Private Google Access endpoints."
  direction   = "EGRESS"
  priority    = 4030

  source_ranges = ["0.0.0.0/0"]
  destination_ranges = [
    "199.36.153.4/30", # RESTRICTED Google Front Ends (GFEs)
    "199.36.153.8/30", # PRIVATE GFEs
    "34.126.0.0/18"    # Direct to certain Google APIs from Compute VMs, bypasses GFEs 
  ]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  # UNCOMMENT TO ENABLE LOGGING. GENERALLY NOT REQUIRED.
  #log_config {
  #    metadata = "EXCLUDE_ALL_METADATA"
  #}
}

# PERMIT TRAFFIC FROM SERVERLESS INFRASTRUCTURE TO VPC CONNECTOR VMS
# MORE INFO ON THIS HERE:
# https://cloud.google.com/vpc/docs/configure-serverless-vpc-access#allow-ranges
resource "google_compute_firewall" "ALLOW_VPC_CONNECTOR_INFRA_INGRESS" {
  name        = "allow-vpc-connector-infra-${var.VPC_NAME}"
  network     = var.VPC_NAME
  description = "Allows INGRESS traffic sourced from Google's underlying Serverless infrastructure to the VPC Connector VMs."
  direction   = "INGRESS"
  priority    = 4040

  target_tags   = ["vpc-connector"]
  source_ranges = ["35.199.224.0/19"]

  allow {
    protocol = "tcp"
  }

  #log_config {
  #  metadata = "INCLUDE_ALL_METADATA"
  #}
}

# DENY ALL TRAFFIC SOURCED FROM SERVERLESS VPC CONNECTORS VIA UNIVERSAL NETWORK TAG
resource "google_compute_firewall" "DENY_VPC_CONNECTORS_INGRESS" {
  name        = "deny-vpc-connectors-${var.VPC_NAME}"
  network     = var.VPC_NAME
  description = "Denies INGRESS traffic source from any/all Serverless VPC Connectors."
  direction   = "INGRESS"
  priority    = 4050

  source_tags        = ["vpc-connector"]
  destination_ranges = [var.VPC_IP_RANGE]

  deny {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# ALLOW LOAD BALANCER PROXY NETWORK INGRESS
resource "google_compute_firewall" "ALLOW_PROXYNET_INGRESS" {
  name        = "allow-proxynet-ingress-${var.VPC_NAME}"
  network     = var.VPC_NAME
  description = "Permits INGRESS traffic from specified load balancer proxy network range."
  direction   = "INGRESS"
  priority    = 4060

  source_ranges = var.PROXY_NET_IP_RANGES
  target_tags   = ["lb-backend"]

  allow {
    protocol = "all"
  }

  # UNCOMMENT TO ENABLE LOGGING. GENERALLY NOT REQUIRED.
  #log_config {
  #  metadata = "EXCLUDE_ALL_METADATA"
  #}
}

# INTRA-VPC EGRESS ALLOW
resource "google_compute_firewall" "ALLOW_INTRA_EGRESS" {
  name        = "allow-intra-egress-${var.VPC_NAME}"
  network     = var.VPC_NAME
  description = "Permits EGRESS traffic sourced from within the given IP range. Should be the ENTIRE network reserved for the VPC. With all egress traffic allowed and ingress traffic denied, exceptions can be created almost entirely based on INGRESS traffic."
  direction   = "EGRESS"
  priority    = 4070

  source_ranges      = [var.VPC_IP_RANGE]
  destination_ranges = [var.VPC_IP_RANGE]

  allow {
    protocol = "all"
  }

  # UNCOMMENT TO ENABLE LOGGING FOR TROUBLESHOOTING. GENERALLY SHOULD NOT BE NEEDED, NO POINT LOGGING WHEN INTRA INGRESS DENY RULE WILL BE LOGGING THE SAME TRAFFIC STREAM(S). COULD HELP TROUBLESHOOT EDGE CASES.

  #log_config {
  #    metadata = "EXCLUDE_ALL_METADATA"
  #}
}

# ALLOW IAP TCP FORWARDING FOR SSH AND RDP
# MORE INFO ON THIS HERE:
# https://cloud.google.com/iap/docs/using-tcp-forwarding
resource "google_compute_firewall" "ALLOW_IAP_TCP_INGRESS" {
  name        = "allow-iap-tcp-ingress-${var.VPC_NAME}"
  network     = var.VPC_NAME
  description = "Permits INGRESS traffic from IAP TCP ranges."
  direction   = "INGRESS"
  priority    = 4080

  source_ranges      = ["35.235.240.0/20"]
  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports = ["22", "3389"]
  }

  # UNCOMMENT TO ENABLE LOGGING. GENERALLY NOT REQUIRED.
  #log_config {
  #  metadata = "INCLUDE_ALL_METADATA"
  #}
}










# DEFAULT INGRESS AND EGRESS DENY
resource "google_compute_firewall" "DENY_DEFAULT_INGRESS" {
  name        = "deny-default-ingress-${var.VPC_NAME}"
  network     = var.VPC_NAME
  description = "Explicit default ingress deny rule."
  direction   = "INGRESS"
  priority    = 5000

  source_ranges      = ["0.0.0.0/0"]
  destination_ranges = [var.VPC_IP_RANGE]

  deny {
    protocol = "all"
  }

  log_config {
    metadata = "EXCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "DENY_DEFAULT_EGRESS" {
  name        = "deny-default-egress-${var.VPC_NAME}"
  network     = var.VPC_NAME
  description = "Explicit default egress deny rule."
  direction   = "EGRESS"
  priority    = 5000

  source_ranges      = [var.VPC_IP_RANGE]
  destination_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  log_config {
    metadata = "EXCLUDE_ALL_METADATA"
  }
}