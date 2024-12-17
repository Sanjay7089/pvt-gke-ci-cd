module "gke_private_cluster" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version = "22.1.0"

  project_id                      = var.gke_config.project_id
  name                            = var.gke_config.name
  region                          = var.gke_config.region
  network                         = var.gke_config.network
  subnetwork                      = var.gke_config.subnetwork
  ip_range_pods                   = var.gke_config.secondary_ranges[0] # Assuming 'pod' is the first secondary range
  ip_range_services               = var.gke_config.secondary_ranges[1] # Assuming 'svc' is the second secondary range
  release_channel                 = var.gke_config.release_channel
  enable_vertical_pod_autoscaling = var.gke_config.enable_vertical_pod_autoscaling
  enable_private_endpoint         = var.gke_config.enable_private_endpoint
  enable_private_nodes            = var.gke_config.enable_private_nodes
  master_ipv4_cidr_block          = var.gke_config.master_ipv4_cidr_block
  #   deletion_protection             = var.gke_config.deletion_protection
  master_authorized_networks = var.gke_config.master_authorized_networks
  create_service_account     = var.gke_config.create_service_account
  service_account            = var.gke_config.service_account
}
