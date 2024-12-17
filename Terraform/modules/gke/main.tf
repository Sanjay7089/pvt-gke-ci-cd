# module "gke_private_cluster" {
#   source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
#   version = "22.1.0"

#   project_id                      = var.gke_config.project_id
#   name                            = var.gke_config.name
#   region                          = var.gke_config.region
#   network                         = var.gke_config.network
#   subnetwork                      = var.gke_config.subnetwork
#   ip_range_pods                   = var.gke_config.secondary_ranges[0] # Assuming 'pod' is the first secondary range
#   ip_range_services               = var.gke_config.secondary_ranges[1] # Assuming 'svc' is the second secondary range
#   release_channel                 = var.gke_config.release_channel
#   enable_vertical_pod_autoscaling = var.gke_config.enable_vertical_pod_autoscaling
#   enable_private_endpoint         = var.gke_config.enable_private_endpoint
#   enable_private_nodes            = var.gke_config.enable_private_nodes
#   master_ipv4_cidr_block          = var.gke_config.master_ipv4_cidr_block
#   #   deletion_protection             = var.gke_config.deletion_protection
#   master_authorized_networks = var.gke_config.master_authorized_networks
#   create_service_account     = var.gke_config.create_service_account
#   node_pools = var.gke_config.node_pools
# }




resource "google_container_cluster" "pvt-gke-autopilot" {
  name     = var.gke_config.name
  location = var.gke_config.region
  project = var.gke_config.project_id
  # Enable Autopilot
  enable_autopilot = var.gke_config.enable_autopilot

  # Network Configuration
  network    = var.gke_config.network
  subnetwork = var.gke_config.subnetwork

  # Private Cluster Configuration
  private_cluster_config {
    enable_private_endpoint = var.gke_config.enable_private_endpoint
    enable_private_nodes    = var.gke_config.enable_private_nodes
    master_ipv4_cidr_block  = var.gke_config.master_ipv4_cidr_block
  }

  # Master Authorized Networks
  dynamic "master_authorized_networks_config" {
    for_each = length(var.gke_config.master_authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.gke_config.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  # Networking IP Allocation Policy
  ip_allocation_policy {
    cluster_secondary_range_name  = var.gke_config.pod_range
    services_secondary_range_name = var.gke_config.service_range
  }

  # Release Channel Configuration
  release_channel {
    channel = var.gke_config.release_channel
  }

  # Workload Identity Configuration
#   workload_identity_config {
#     workload_pool = "${var.gke_config.project_id}.svc.id.goog"
#   }

  # Service Account Configuration for Autoscaling Defaults
  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = var.gke_config.auto_provisioning_defaults.service_account
    }
  }
}
