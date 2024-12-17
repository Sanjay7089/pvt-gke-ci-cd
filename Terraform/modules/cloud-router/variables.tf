variable "cloud_router_object" {
  description = "Cloud Router Details"
  type = object({
    project_id   = string
    network_name = string
    region       = string
    router_name  = string
    nats = list(object({
      name                                = string
      nat_ip_allocate_option              = optional(string)
      source_subnetwork_ip_ranges_to_nat  = optional(string)
      nat_ips                             = optional(list(string), [])
      
    }))

    }
  )

}
