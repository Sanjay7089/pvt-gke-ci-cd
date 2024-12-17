/**
 * Copyright 2022 Google LLC
 *
 * This software is provided as is, without warranty or representation for any use or purpose. 
 * Your use of it is subject to your agreement with Google.
 *     
 */


# module "vpc" {
#   source = "terraform-google-modules/network/google"
#   version                                = "~> 5.1"
#   auto_create_subnetworks                = var.vpc_objects.auto_create_subnetworks != null ? var.vpc_objects.auto_create_subnetworks : false
#   delete_default_internet_gateway_routes = var.vpc_objects.delete_default_internet_gateway_routes != null ? var.vpc_objects.delete_default_internet_gateway_routes : false
#   description                            = var.vpc_objects.description != null ? var.vpc_objects.description : ""
#   firewall_rules                         = var.vpc_objects.firewall_rules != null ? var.vpc_objects.firewall_rules : []
#   mtu                                    = var.vpc_objects.mtu != null ? var.vpc_objects.mtu : 0
#   network_name                           = var.vpc_objects.network_name
#   project_id                             = var.vpc_objects.project_id
#   routes                                 = var.vpc_objects.routes != null ? var.vpc_objects.routes : []
#   routing_mode                           = var.vpc_objects.routing_mode != null ? var.vpc_objects.routing_mode : "GLOBAL"
#   secondary_ranges                       = var.vpc_objects.secondary_ranges != null ? var.vpc_objects.secondary_ranges : {}
#   shared_vpc_host                        = var.vpc_objects.shared_vpc_host != null ? var.vpc_objects.shared_vpc_host : false
#   subnets                                = var.vpc_objects.subnets != null ? var.vpc_objects.subnets : []
# }

locals {
  mutliple_vpc_obj = {
    for a in var.vpc_objects : a.network_name => a
  }
}
# Module for creating multiple VPCs
module "vpcs" {
  for_each = local.mutliple_vpc_obj

  source = "terraform-google-modules/network/google"
  version = "~> 5.1"

  auto_create_subnetworks                = lookup(each.value, "auto_create_subnetworks", false)
  delete_default_internet_gateway_routes = lookup(each.value, "delete_default_internet_gateway_routes", false)
  description                            = lookup(each.value, "description", "")
  firewall_rules                         = lookup(each.value, "firewall_rules", [])
  mtu                                    = lookup(each.value, "mtu", null)
  network_name                           = each.value.network_name
  project_id                             = each.value.project_id
  routes                                 = lookup(each.value, "routes", [])
  routing_mode                           = lookup(each.value, "routing_mode", "GLOBAL")
  secondary_ranges                       = lookup(each.value, "secondary_ranges", {})
  
  shared_vpc_host                        = lookup(each.value, "shared_vpc_host", false)
  
  subnets                                = each.value.subnets
}

