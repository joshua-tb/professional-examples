output "VPC" {
  value       = google_compute_network.VPC
  description = "Full VPC object."
}

output "VPC_ROUTERS" {
  value = { for k, router in google_compute_router.VPC_ROUTER :
  k => router }
  description = "List of full objects for the VPC ROUTERS."
}

output "COMMON_SUBNET" {
  value = { for k, subnet in google_compute_subnetwork.COMMON_SUBNET :
  k => subnet }
  description = "Full object for the COMMON SUBNETWORK."
}

output "REGIONAL_PROXY_ONLY_SUBNET" {
  value = [for subnet in google_compute_subnetwork.REGIONAL_PROXY_ONLY_SUBNET :
  subnet.ip_cidr_range]
  description = "List of IP ranges assigned to the REGIONAL PROXY-ONLY SUBNETWORKS."
}