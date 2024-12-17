# variable "vpc_object" {
#   description = "VPC Details"
#   type = object({
#     project_id                             = string
#     network_name                           = string
#     description                            = optional(string)
#     auto_create_subnetworks                = optional(bool)
#     subnets                                = optional(list(map(string)))
#     secondary_ranges                       = optional(map(list(object({ range_name = string, ip_cidr_range = string }))))
#     routing_mode                           = optional(string)
#     routes                                 = optional(list(map(string)))
#     delete_default_internet_gateway_routes = optional(bool)
#     firewall_rules                         = optional(list(any))
#     mtu                                    = optional(number)
#     shared_vpc_host                        = optional(bool)
#     }
#   )
# }
variable "vpc_objects" {
  description = "List of configuration objects for VPCs"

  type = list(object({
    auto_create_subnetworks                = optional(bool)
    delete_default_internet_gateway_routes = optional(bool)
    description                            = optional(string)
    firewall_rules                         = optional(list(object({
      name        = string
      description = string
      direction   = string
      priority    = number
      ranges      = list(string)
      allow       = list(object({
        protocol = string
        ports    = list(string)
      }))
      deny        = list(object({
        protocol = string
        ports    = list(string)
      }))
    })))
    mtu                                    = optional(number)
    network_name                           = string
    project_id                             = string
    routes                                 = optional(list(object({
      name   = string
      dest   = string
      next_hop_ip   = optional(string)
      next_hop_instance   = optional(string)
    })))
    routing_mode                           = optional(string)
    secondary_ranges                       = optional(map(list(object({
      range_name    = string
      ip_cidr_range = string
    }))))
    
    shared_vpc_host                        = optional(bool)
    
    subnets                                = list(object({
      subnet_name           = string
      subnet_ip             = string
      subnet_region         = string
      subnet_private_access = bool
    }))
  }))
}
