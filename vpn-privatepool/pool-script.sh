#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Check if GKE cluster VPN gateway exists
if ! gcloud compute vpn-gateways describe gke-cluster-vpn-gateway --region us-central1 &> /dev/null; then
  echo "Creating GKE cluster VPN gateway..."
  gcloud compute vpn-gateways create gke-cluster-vpn-gateway \
      --network=gke-cluster-vpc \
      --region=us-central1 \
      --stack-type=IPV4_ONLY
else
  echo "GKE cluster VPN gateway already exists."
fi

# Check if Private Pool VPN gateway exists
if ! gcloud compute vpn-gateways describe private-pool-vpn-gateway --region us-central1 &> /dev/null; then
  echo "Creating Private Pool VPN gateway..."
  gcloud compute vpn-gateways create private-pool-vpn-gateway \
      --network=private-pool-vpc \
      --region=us-central1 \
      --stack-type=IPV4_ONLY
else
  echo "Private Pool VPN gateway already exists."
fi

# Create routers for GKE cluster and private pool if they don't exist
if ! gcloud compute routers describe vpn-gke-cluster-vpc --region us-central1 &> /dev/null; then
  echo "Creating router for GKE cluster..."
  gcloud compute routers create vpn-gke-cluster-vpc \
      --region=us-central1 \
      --network=gke-cluster-vpc \
      --asn=64518
else
  echo "Router for GKE cluster already exists."
fi

if ! gcloud compute routers describe vpn-private-pool-vpc --region us-central1 &> /dev/null; then
  echo "Creating router for Private Pool..."
  gcloud compute routers create vpn-private-pool-vpc \
      --region=us-central1 \
      --network=private-pool-vpc \
      --asn=64522
else
  echo "Router for Private Pool already exists."
fi

# Create VPN tunnels if they don't exist
if ! gcloud compute vpn-tunnels describe gke-cluster-vpc-0 --region us-central1 &> /dev/null; then
  echo "Creating VPN tunnel for GKE cluster..."
  gcloud compute vpn-tunnels create gke-cluster-vpc-0 \
      --peer-gcp-gateway=private-pool-vpn-gateway \
      --region=us-central1 \
      --ike-version=2 \
      --shared-secret=e959060652d0eee39c40312c7916d076 \
      --router=vpn-gke-cluster-vpc \
      --vpn-gateway=gke-cluster-vpn-gateway \
      --interface=0
else
  echo "VPN tunnel for GKE cluster already exists."
fi

if ! gcloud compute vpn-tunnels describe private-pool-vpc-0 --region us-central1 &> /dev/null; then
  echo "Creating VPN tunnel for Private Pool..."
  gcloud compute vpn-tunnels create private-pool-vpc-0 \
      --peer-gcp-gateway=gke-cluster-vpn-gateway \
      --region=us-central1 \
      --ike-version=2 \
      --shared-secret=e959060652d0eee39c40312c7916d076 \
      --router=vpn-private-pool-vpc \
      --vpn-gateway=private-pool-vpn-gateway \
      --interface=0
else
  echo "VPN tunnel for Private Pool already exists."
fi

# Add interfaces to routers if they don't exist (similar checks can be added)
gcloud compute routers add-interface vpn-gke-cluster-vpc \
    --interface-name=gke-cluster-vpc-0 \
    --ip-address=169.254.0.1 \
    --mask-length=16 \
    --vpn-tunnel=gke-cluster-vpc-0 \
    --region=us-central1 || echo "Interface for GKE cluster router already exists."

gcloud compute routers add-interface vpn-private-pool-vpc \
    --interface-name=private-pool-vpc-0 \
    --ip-address=169.254.0.2 \
    --mask-length=16 \
    --vpn-tunnel=private-pool-vpc-0 \
    --region=us-central1 || echo "Interface for Private Pool router already exists."

# Add BGP peers to routers (similar checks can be added)
gcloud compute routers add-bgp-peer vpn-gke-cluster-vpc \
    --peer-name=gke-cluster-vpn-gateway \
    --interface=gke-cluster-vpc-0 \
    --peer-ip-address=169.254.0.2 \
    --peer-asn=64522 \
    --region=us-central1 || echo "BGP peer for GKE cluster router already exists."

gcloud compute routers add-bgp-peer vpn-private-pool-vpc \
    --peer-name=private-pool-vpn-gateway \
    --interface=private-pool-vpc-0 \
    --peer-ip-address=169.254.0.1 \
    --peer-asn=64518 \
    --region=us-central1 || echo "BGP peer for Private Pool router already exists."
