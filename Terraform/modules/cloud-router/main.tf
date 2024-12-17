


module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"
  name    = var.cloud_router_object.router_name
  project = var.cloud_router_object.project_id
  network = var.cloud_router_object.network_name
  region  = var.cloud_router_object.region
  nats =    var.cloud_router_object.nats
}