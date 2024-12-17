resource "local_file" "default" {
  file_permission = "0644"
  filename        = "Terraform/env/dev/backend.tf"

  # You can store the template in a file and use the templatefile function for
  # more modularity, if you prefer, instead of storing the template inline as
  # we do here.
  content = <<-EOT
 
  EOT
}

/******************************************
   VPC 
 *****************************************/


module "vpcs" {
  source      = "../../modules/vpc"
  vpc_objects = var.vpc_objects
  #   depends_on = [module.api-enable]

}

/******************************************
   Cloud Router 
 *****************************************/

module "cloud-router" {
  source              = "../../modules/cloud-router"
  cloud_router_object = var.cloud_router_object
  depends_on          = [module.vpcs]
}

/******************************************
   GCS bucket 
 *****************************************/

# module "tf-state-bucket" {
#   source      = "../../modules/cloud-storage"
#   buckets_obj = var.buckets_obj
# }

/******************************************
   GKE
 *****************************************/

module "gke" {
  source     = "../../modules/gke"
  gke_config = var.gke_config
  depends_on = [module.vpcs]
}

