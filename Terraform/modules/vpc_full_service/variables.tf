variable "VPC_NAME" {
  type        = string
  description = "Name of the VPC to be created. CONSIDER LINKING TO .name DATA RESOURCE ATTRIBUTE."
}

variable "DESCRIPTION" {
  type        = string
  description = "Description of the VPC."
}

variable "VPC_ROUTING_MODE" {
  type        = string
  description = "Internal routing mode for the VPC. Can be either 'GLOBAL' or 'REGIONAL'."
  default     = "REGIONAL"
}

variable "MTU_BYTES" {
  type        = number
  description = "Size of the MTU (Maximum Transmission Unit) for the VPC in bytes. Should be 1500, or 8896."
  default     = 1500
}

variable "REGIONS" {
  type = map(object(
    {
      IDX  = string
      NAME = string
      ASN  = string
    }
  ))
  description = "Map of objects for each target region containing the region name and assigned ASN."
}

variable "VPC_IP_RANGE" {
  type        = string
  description = "Summarized IP range assigned to the VPC. Should be a /14."
}

variable "COMMON_SUBNET_USERS" {
  type        = list(string)
  description = "List of users allowed to use the subnet. Can be added upon request."
  default     = []
}

variable "CREATE_COMMON_SUBNET" {
  type        = bool
  description = "If true, creates a 'common' subnet which can be used by service projects upon request."
  default     = true
}

variable "COMMON_SUBNET_REGION" {
  type        = string
  description = "List of users allowed to use the subnet. Can be added upon request."
  default     = ""
}

variable "CUSTOM_ADVERTISED_ROUTES" {
  type        = list(string)
  description = "List of custom routes to be advertised to BGP neighbors, should be expressed WITH CIDR notation."
  default     = []
}

variable "EXPORT_CUSTOM_ROUTES" {
  type        = bool
  description = "If True, exports any configured custom routes to the VPC Peer."
  default     = true
}

variable "IMPORT_CUSTOM_ROUTES" {
  type        = bool
  description = "If True, imports any configured custom routes into the Shared VPC route table."
  default     = false
}

variable "ENABLE_APIS" {
  type        = bool
  description = "Enables the activation of APIs or Services required for the module's resources. Set to 'false' to disable API activation."
  default     = true
}