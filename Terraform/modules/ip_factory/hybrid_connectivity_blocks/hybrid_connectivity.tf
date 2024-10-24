locals {
  OCTET_ID = split(".", var.VPC_IP_RANGE)[1]

  # Assigns VLAN IDs based on active regions and octet ID
  VLAN_ID_INDEX = [for idx, region in var.REGIONS :
    local.OCTET_ID <= 100 ? "1${local.OCTET_ID}" + "${(region.IDX)}00" :
    "1${local.OCTET_ID}" + "${idx}000"
  ]

  REGION_INDEX = { for key, region in var.REGIONS :
  (region.IDX) => region.NAME }


  # Allocates FOUR subnets, one for each possible region
  VA_REGION_RANGES_INDEX = cidrsubnets("169.254.${local.OCTET_ID}.0/25", 2, 2, 2, 2)

  VA_REGION_RANGES_MAP = [for idx, range in local.VA_REGION_RANGES_INDEX :
    {
      "IDX"      = idx
      "REGION"   = try(local.REGION_INDEX[idx], null)
      "IP_RANGE" = range
    }
  ]

  # For each allocation, allocates FOUR subnets, one for each possible DIC. 
  VA_DIC_RANGES_INDEX = [for idx, range in local.VA_REGION_RANGES_INDEX :
  cidrsubnets(range, 2, 2, 2, 2)]

  # For each allocation, and for each defined DIC, assign a CIDR block
  VA_DIC_RANGES_MAP = [for idx-r, region in local.VA_DIC_RANGES_INDEX :
    { for idx-d, range in region : "${idx-r}-${idx-d}" => {
      "NAME"        = try(var.DICS_LIST[idx-d].NAME, null),
      "REGION"      = try(local.VA_REGION_RANGES_MAP[idx-r].REGION, null)
      "IP_RANGE"    = local.VA_DIC_RANGES_INDEX[idx-r][idx-d]
      "URL"         = try(var.DICS_LIST[idx-d].URL, null)
      "DESCRIPTION" = try(var.DICS_LIST[idx-d].DESCRIPTION, null)
      }
    }
  ]

  VA_DIC_RANGES_ASSIGNED = flatten([for idx, region in local.VA_DIC_RANGES_MAP :
    [for dic in region :
      {
        "NAME"        = dic.NAME
        "REGION"      = dic.REGION
        "IP_RANGE"    = dic.IP_RANGE
        "URL"         = dic.URL
        "DESCRIPTION" = dic.DESCRIPTION
      }
      if dic.NAME != null
    ]
  ])





  # Allocates FOUR /27 subnets, one for each possible region
  VPNGW_REGION_RANGES_INDEX = cidrsubnets("192.168.${local.OCTET_ID}.0/25", 2, 2, 2, 2)

  # For each active region, assign a CIDR block
  VPNGW_REGION_RANGES_MAP = [for idx, range in local.VPNGW_REGION_RANGES_INDEX :
    {
      "IDX"      = idx
      "REGION"   = try(local.REGION_INDEX[idx], null)
      "IP_RANGE" = range
    }
  ]


  # For each block assigned, allocates FOUR /29 subnets, one for each possible DIC
  VPNGW_DIC_RANGES_INDEX = [for idx, range in local.VPNGW_REGION_RANGES_INDEX :
  cidrsubnets(range, 2, 2, 2, 2)]

  # For each allocation and each defined DIC, assign a CIDR block
  VPNGW_DIC_RANGES_MAP = [for idx-r, region in local.VPNGW_DIC_RANGES_INDEX :
    { for idx-d, range in region :
      "${idx-r}-${idx-d}" => {
        "NAME"        = try(var.DICS_LIST[idx-d].NAME, null),
        "REGION"      = try(local.VA_REGION_RANGES_MAP[idx-r].REGION, null)
        "IP_RANGE"    = local.VPNGW_DIC_RANGES_INDEX[idx-r][idx-d]
        "URL"         = try(var.DICS_LIST[idx-d].URL, null)
        "DESCRIPTION" = try(var.DICS_LIST[idx-d].DESCRIPTION, null)
      }
    }
  ]

  VPNGW_DIC_RANGES_ASSIGNED = flatten([for idx, region in local.VPNGW_DIC_RANGES_MAP :
    [for dic in region :
      {
        "REGION"   = dic.REGION
        "IP_RANGE" = dic.IP_RANGE
        "DIC"      = dic.NAME
      }
      if dic.NAME != null
    ]
  ])

  #For each assigned block, assign a /32 host IP
  VPNGW_INTS_REMOTE_ADDR = [for idx, block in local.VPNGW_DIC_RANGES_INDEX :
  cidrhost("192.168.${local.OCTET_ID}.128/25", 1 + idx)] #+ block[index(block, )] ]
  #tonumber("${local.VPN_GW_REGIONAL_INDEX[block]}"))]





  # Allocates FOUR /27 subnets, one for each region
  TUNNEL_REGION_RANGES_INDEX = cidrsubnets("169.254.${local.OCTET_ID}.128/25", 2, 2, 2, 2)

  # For each active region, assign a CIDR block.
  TUNNEL_REGION_RANGES_MAP = [for idx, range in local.TUNNEL_REGION_RANGES_INDEX :
    {
      "IDX"      = idx
      "REGION"   = try(local.REGION_INDEX[idx], null)
      "IP_RANGE" = range
    }
  ]



  # For each block assigned, allocates FOUR /29 subnets, one for each possible DIC
  TUNNEL_DICS_RANGES_INDEX = [for block in local.TUNNEL_REGION_RANGES_INDEX :
    cidrsubnets(block, 2, 2, 2, 2)
  ]

  # For each allocation and for each DIC, assign a CIDR block
  TUNNEL_DICS_RANGES_MAP = [for idx-r, region in local.TUNNEL_DICS_RANGES_INDEX :
    { for idx-d, range in region :
      "${idx-r}-${idx-d}" => {
        "NAME"        = try(var.DICS_LIST[idx-d].NAME, null),
        "REGION"      = try(local.VA_REGION_RANGES_MAP[idx-r].REGION, null)
        "IP_RANGE"    = local.TUNNEL_DICS_RANGES_INDEX[idx-r][idx-d]
        #"URL"         = try(var.DICS_LIST[idx-d].URL, null)
        #"DESCRIPTION" = try(var.DICS_LIST[idx-d].DESCRIPTION, null)
      }
    }
  ]

  # For each assigned block, allocates TWO /30 subnets, one for each tunnel interface
  TUNNEL_INTS_RANGES_INDEX = [for idx, region in local.TUNNEL_DICS_RANGES_MAP :
    flatten([for dic in region :
    cidrsubnets(dic.IP_RANGE, 1, 1)])
  ]

  # For each /30 allocated, assign VPC ROUTER interfaces
  TUNNEL_INTS_ADDRS_VPC_ROUTER = [for idx-r, ranges in local.TUNNEL_INTS_RANGES_INDEX :
    [for idx-a, addr in ranges :
    cidrhost(ranges[idx-a], 1)]
  ]


  # For each /30 allocated, assign REMOTE ROUTER interfaces
  TUNNEL_INTS_ADDRS_REMOTE_ROUTERS = [for idx-r, ranges in local.TUNNEL_INTS_RANGES_INDEX :
    [for idx-a, addr in ranges :
    cidrhost(ranges[idx-a], 2)]
  ]



  # Aggregates /30 interface allocations into a map to be used for resource creation
  VPC_ROUTER_TUNNEL_INT_IPS = { for k, v in flatten(
    [for idx-r, region in local.TUNNEL_REGION_RANGES_MAP :
      [for idx-d, dics in var.DICS_LIST :
        {
          "REGION" = region.REGION
          "GW1"    = local.TUNNEL_INTS_ADDRS_VPC_ROUTER[idx-r][idx-d * 2]     #0
          "GW2"    = local.TUNNEL_INTS_ADDRS_VPC_ROUTER[idx-r][idx-d * 2 + 1] #2
          "DIC_ID" = idx-d
        }
      ] if region.REGION != null
    ]) : "${upper(replace("${v.REGION}", "-", "_"))}_${v.DIC_ID}" => v
  }

  REMOTE_TUNNEL_INT_IPS = { for k, v in flatten(
    [for idx-r, region in local.TUNNEL_REGION_RANGES_MAP :
      [for idx-d, dics in var.DICS_LIST :
        {
          "REGION" = region.REGION
          "GW1"    = local.TUNNEL_INTS_ADDRS_REMOTE_ROUTERS[idx-r][idx-d * 2]
          "GW2"    = local.TUNNEL_INTS_ADDRS_REMOTE_ROUTERS[idx-r][idx-d * 2 + 1]
          "DIC_ID" = idx-d
        }
      ] if region.REGION != null
    ]) : "${upper(replace("${v.REGION}", "-", "_"))}_${v.DIC_ID}" => v
  }
}