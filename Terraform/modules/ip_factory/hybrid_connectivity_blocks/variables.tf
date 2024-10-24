variable "VPC_IP_RANGE" {
  type        = string
  description = "Summarized CIDR range for the entire VPC."
}

variable "DICS_LIST" {
  type        = list(map(string))
  description = "List of maps containing Dedicated Interconnect details."
  default = [
    {
      NAME        = null
      URL         = null
      DESCRIPTION = null
    },
    {
      NAME        = null
      URL         = null
      DESCRIPTION = null
    },
    {
      NAME        = null
      URL         = null
      DESCRIPTION = null
    },
    {
      NAME        = null
      URL         = null
      DESCRIPTION = null
    },
  ]
}

variable "REGIONS" {
  type        = map(map(string))
  description = "Map of maps for each target region containing the region name and assigned ASN."
}