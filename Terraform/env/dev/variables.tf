variable "cloud_router_object" {
  description = "Cloud Router Details"
  type = object({
    project_id   = string
    network_name = string
    region       = string
    router_name  = string
    nats = list(object({
      name                               = string
      nat_ip_allocate_option             = optional(string)
      source_subnetwork_ip_ranges_to_nat = optional(string)
      nat_ips                            = optional(list(string), [])


    }))

    }
  )

}

variable "buckets_obj" {
  description = "List of buckets & IAM permissions"
  type = list(object({
    project            = string
    bucket_name        = string
    location           = optional(string)
    prefix             = optional(string)
    bucket_permissions = optional(map(list(string)))

    conditional_bindings = optional(list(object({
      role        = string
      title       = string
      description = string
      expression  = string
      members     = list(string)
      }))
    )

    versioning           = optional(map(bool))
    encryption_key_names = optional(map(string))

    lifecycle_rules = optional(set(object({
      action    = map(string)
      condition = map(string)
    })))

    admins                   = optional(list(string))
    bucket_admins            = optional(map(string))
    bucket_creators          = optional(map(string))
    bucket_hmac_key_admins   = optional(map(string))
    bucket_policy_only       = optional(map(bool))
    bucket_storage_admins    = optional(map(string))
    bucket_viewers           = optional(map(string))
    cors                     = optional(set(any))
    creators                 = optional(list(string))
    folders                  = optional(map(list(string)))
    force_destroy            = optional(map(bool))
    hmac_key_admins          = optional(list(string))
    labels                   = map(string)
    logging                  = optional(any)
    randomize_suffix         = optional(bool)
    retention_policy         = any
    set_admin_roles          = optional(bool)
    set_creator_roles        = optional(bool)
    set_hmac_key_admin_roles = optional(bool)
    set_storage_admin_roles  = optional(bool)
    set_viewer_roles         = optional(bool)
    storage_admins           = optional(list(string))
    storage_class            = optional(string)
    viewers                  = optional(list(string))
    website                  = optional(map(any))
    }
  ))
  validation {
    condition = length([
      for data in var.buckets_obj : true
    if contains(keys(data.labels), "app") && contains(keys(data.labels), "owner")]) == length(var.buckets_obj)
    error_message = "You must specify callcenter and owner labels in user_labels."
  }
}

variable "gke_config" {
  description = "Configuration for GKE private cluster"
  type = object({
    project_id                      = string
    region                          = string
    name                            = string
    network                         = string
    subnetwork                      = string
    master_ipv4_cidr_block          = string
    service_account                 = string
    enable_vertical_pod_autoscaling = bool
    enable_private_endpoint         = bool
    enable_private_nodes            = bool
    release_channel                 = string
    secondary_ranges                = list(string)
    master_authorized_networks = list(object({
      cidr_block   = string
      display_name = string
    }))
  })
}

variable "vpc_objects" {
  description = "List of configuration objects for VPCs"

  type = list(object({
    auto_create_subnetworks                = optional(bool)
    delete_default_internet_gateway_routes = optional(bool)
    description                            = optional(string)
    firewall_rules = optional(list(object({
      name        = string
      description = string
      direction   = string
      priority    = number
      ranges      = list(string)
      allow = list(object({
        protocol = string
        ports    = list(string)
      }))
      deny = list(object({
        protocol = string
        ports    = list(string)
      }))
    })))
    mtu          = optional(number)
    network_name = string
    project_id   = string
    routes = optional(list(object({
      name              = string
      dest              = string
      next_hop_ip       = optional(string)
      next_hop_instance = optional(string)
    })))
    routing_mode = optional(string)
    secondary_ranges = optional(map(list(object({
      range_name    = string
      ip_cidr_range = string
    }))))

    shared_vpc_host = optional(bool)

    subnets = list(object({
      subnet_name           = string
      subnet_ip             = string
      subnet_region         = string
      subnet_private_access = bool
    }))
  }))
}
