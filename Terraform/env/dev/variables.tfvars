buckets_obj = [
  {
    ## BUCKET WITH ALL THE INPUT ATTRIBUTES
    ## AS SPECIIFIED IN THE TERRAFORM GOOGLE MODULES DOCS
    bucket_name = "tfstate-bucket-gcp"
    project     = "poc-project-443614"
    location    = "us-central1"
    prefix      = ""
    versioning = {
      tfstate-bucket-gcp = true
    }
    bucket_permissions = {
      "roles/storage.admin" = [
        "user:sanjayjatsanjay22@gmail.com"
      ]
    }
    labels = {
      app   = "terraform-state",
      owner = "quantiphi"
    }

    admins                   = []
    bucket_admins            = {}
    bucket_creators          = {}
    bucket_hmac_key_admins   = {}
    bucket_policy_only       = {}
    bucket_storage_admins    = {}
    bucket_viewers           = {}
    randomize_suffix         = false
    retention_policy         = {}
    set_admin_roles          = false
    set_creator_roles        = false
    set_hmac_key_admin_roles = false
    set_storage_admin_roles  = false
    set_viewer_roles         = false
    storage_admins           = []
    storage_class            = "STANDARD"
    viewers                  = []
    website                  = {}
  }
]

vpc_objects = [
  {
    auto_create_subnetworks : false,
    delete_default_internet_gateway_routes : false,
    description : "Private Pool VPC",
    firewall_rules : [],
    mtu : null,
    network_name : "private-pool-vpc",
    project_id : "poc-project-443614",
    routes : [],
    routing_mode : "GLOBAL",
    secondary_ranges : {},
    shared_vpc_host : false,
    subnets : [
      {
        subnet_name : "private-pool-subnet",
        subnet_ip : "10.6.5.0/24",
        subnet_region : "us-central1",
        subnet_private_access : true,
      }
    ]
  },
  {
    auto_create_subnetworks : false,
    delete_default_internet_gateway_routes : false,
    description : "GKE Cluster VPC",
    firewall_rules : [],
    mtu : null,
    network_name : "gke-cluster-vpc",
    project_id : "poc-project-443614",
    routes : [],
    routing_mode : "GLOBAL",
    secondary_ranges : {
      "gke-cluster-subnet" : [
        { range_name : "pod", ip_cidr_range : "10.10.6.0/24" },
        { range_name : "svc", ip_cidr_range : "10.10.7.0/24" }
      ]
    },
    shared_vpc_host : false,
    subnets : [
      {
        subnet_name : "gke-cluster-subnet",
        subnet_ip : "10.10.5.0/24",
        subnet_region : "us-central1",
        subnet_private_access : true,
      }
    ]
  }
]
cloud_router_object = {
  router_name  = "gke-cluster-vpc-nat-router",
  project_id   = "poc-project-443614",
  network_name = "gke-cluster-vpc",
  region       = "us-central1",
  nats = [
    {
      name                               = "gke-cluster-vpc-nat",
      nat_ips                            = ["ext-ip-nat"],
      source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"



    }
  ]
}
gke_config = {
  project_id                      = "poc-project-443614"
  region                          = "us-central1"
  name                            = "pvt-gke-cluster"
  network                         = "gke-cluster-vpc"
  subnetwork                      = "gke-cluster-subnet"
  master_ipv4_cidr_block          = "10.3.0.0/28"
  service_account                 = "devops-svc@poc-project-443614.iam.gserviceaccount.com"
  enable_vertical_pod_autoscaling = true
  enable_private_endpoint         = true
  enable_private_nodes            = true
  release_channel                 = "REGULAR"
  secondary_ranges                = ["pod", "svc"]
  master_authorized_networks = [
    {
      cidr_block   = "10.10.0.0/16"
      display_name = "vpc-cider-range"
    }
  ]
}
