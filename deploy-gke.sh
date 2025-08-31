# Create project
gcloud projects create "$PROJECT_ID"
gcloud billing projects link "$PROJECT_ID" --billing-account "$BILLING_ACCOUNT_ID"

# Set Region and Zone
gcloud config set project "$PROJECT_ID"
gcloud config set compute/region "$REGION"
gcloud config set compute/zone "$ZONE"

# Enable Required APIs for the project
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  iam.googleapis.com \
  serviceusage.googleapis.com \
  cloudresourcemanager.googleapis.com

# Setup Networking for Cluster
gcloud compute networks create "$NETWORK_NAME" --subnet-mode=custom

gcloud compute networks subnets create "$SUBNET_NAME" \
  --network "$NETWORK_NAME" \
  --region "$REGION" \
  --range "$SUBNET_RANGE" \
  --secondary-range "${POD_RANGE_NAME}=${POD_RANGE_CIDR},${SVC_RANGE_NAME}=${SVC_RANGE_CIDR}"

# Create GKE Cluster
gcloud container clusters create "$CLUSTER_NAME" \
  --zone "$ZONE" \
  --network "$NETWORK_NAME" \
  --subnetwork "$SUBNET_NAME" \
  --enable-ip-alias \
  --cluster-secondary-range-name "$POD_RANGE_NAME" \
  --services-secondary-range-name "$SVC_RANGE_NAME" \
  --release-channel "regular" \
  --machine-type "e2-standard-4" \
  --num-nodes "3"

