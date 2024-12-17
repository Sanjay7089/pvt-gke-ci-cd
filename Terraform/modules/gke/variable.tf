
variable "gke_config" {
  description = "Configuration for GKE private cluster"
  type = object({
    project_id                      = string
    region                          = string
    name = string
    
    network                         = string
    subnetwork                      = string
    master_ipv4_cidr_block         = string
    service_account                 = string
    create_service_account = bool 
    enable_vertical_pod_autoscaling = bool
    enable_private_endpoint         = bool
    enable_private_nodes            = bool
    release_channel                 = string
   secondary_ranges                       = list(string)
    master_authorized_networks      = list(object({
      cidr_block   = string
      display_name = string
    }))
  })
}
