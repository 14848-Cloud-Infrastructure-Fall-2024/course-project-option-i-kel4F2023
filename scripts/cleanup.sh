#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Stop Terraform processes
echo "Stopping Terraform processes..."
pkill terraform || true  # 'true' ensures the script continues even if pkill fails

# Delete Kubernetes resources
echo "Deleting Kubernetes resources..."
kubectl delete deployment --all --ignore-not-found
kubectl delete service --all --ignore-not-found
kubectl delete pod --all --ignore-not-found

# Delete GKE clusters
echo "Deleting GKE clusters..."
gcloud container clusters delete jenkins-sonarqube-cluster --region us-west1-a --quiet || true
gcloud container clusters delete hadoop-cluster --region us-west1-a --quiet || true

# Delete VPC network and subnet
echo "Deleting VPC network and subnet..."
gcloud compute networks subnets delete gke-subnet --region us-west1 --quiet || true
gcloud compute networks delete gke-network --quiet || true

# Delete the service account
echo "Deleting service account..."
SA_NAME="terraform-sa"
PROJECT_ID=$(gcloud config get-value project)
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Remove IAM policy bindings
gcloud projects remove-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/container.admin" || true

gcloud projects remove-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/compute.admin" || true

# Delete the service account
gcloud iam service-accounts delete $SA_EMAIL --quiet || true

# Delete the service account key file
echo "Deleting service account key file..."
rm -f gcp-credentials.json

# Clean up Terraform state
echo "Cleaning up Terraform state..."
cd terraform || exit
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
cd ..

echo "Cleanup complete!"