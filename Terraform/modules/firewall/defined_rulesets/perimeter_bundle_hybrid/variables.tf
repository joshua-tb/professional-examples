variable "HYBRID_RANGES" {
  type        = list(string)
  description = "A list of on-premises or otherwise hybrid IP ranges."
  default     = []
}

variable "VPC_NAME" {
  type        = string
  description = "Name of the target VPC. CONSIDER LINKING TO .name DATA RESOURCE ATTRIBUTE."
}

variable "VPC_IP_RANGE" {
  type        = string
  description = "Entire IP range reserved for the target VPC."

}

variable "PROXY_NET_IP_RANGES" {
  type        = list(any)
  description = "IP ranges allocated for the load balancer proxy-only network."
}

variable "CREATE_HYBRID_RULES" {
  type        = bool
  description = "If true, creates rules permitting ingress/egress traffic to specified hybrid networks."
  default     = false
}