#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Check if the worker pool range already exists
if ! gcloud compute addresses describe worker-pool-range --global &> /dev/null; then
  echo "Creating worker-pool-range..."
  gcloud compute addresses create worker-pool-range \
      --global \
      --purpose=VPC_PEERING \
      --addresses=192.168.0.0 \
      --prefix-length=24 \
      --network=private-pool-vpc
else
  echo "Worker pool range already exists."
fi

# Check if VPC peering connection exists
if ! gcloud services vpc-peerings describe --service=servicenetworking.googleapis.com --ranges=worker-pool-range --network=private-pool-vpc &> /dev/null; then
  echo "Connecting VPC peering..."
  gcloud services vpc-peerings connect \
      --service=servicenetworking.googleapis.com \
      --ranges=worker-pool-range \
      --network=private-pool-vpc
else
  echo "VPC peering connection already exists."
fi

# Update VPC peering settings
gcloud compute networks peerings update servicenetworking-googleapis-com \
    --network=private-pool-vpc \
    --export-custom-routes \
    --no-export-subnet-routes-with-public-ip

# Create the private build worker pool if it doesn't exist
if ! gcloud builds worker-pools describe private-pool --region=us-central1 &> /dev/null; then
  echo "Creating private build worker pool..."
  gcloud builds worker-pools create private-pool \
      --region=us-central1 \
      --peered-network=projects/poc-project-443614/global/networks/private-pool-vpc
else
  echo "Private build worker pool already exists."
fi

# Get GKE peering name and update BGP peers accordingly
export GKE_PEERING_NAME=$(gcloud container clusters describe pvt-gke-cluster --region us-central1 --format='value(privateClusterConfig.peeringName)')

gcloud compute networks peerings update $GKE_PEERING_NAME --network=gke-cluster-vpc --export-custom-routes --no-export-subnet-routes-with-public-ip

IP=$(gcloud compute addresses describe worker-pool-range --global | grep address: | awk '{print $2}')

gcloud compute routers update-bgp-peer vpn-private-pool-vpc --peer-name=private-pool-vpn-gateway --region=us-central1 --advertisement-mode=CUSTOM --set-advertisement-ranges=$IP/24

gcloud compute routers update-bgp-peer vpn-gke-cluster-vpc --peer-name=gke-cluster-vpn-gateway --region=us-central1 --advertisement-mode=CUSTOM --set-advertisement-ranges=10.4.0.0/28

gcloud container clusters update pvt-gke-cluster --enable-master-authorized-networks --region us-central1 --master-authorized-networks=$IP/24
