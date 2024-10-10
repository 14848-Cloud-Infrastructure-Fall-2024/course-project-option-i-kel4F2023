#!/bin/bash

# Stop Terraform processes
echo "Stopping Terraform processes..."
pkill terraform

# Delete Kubernetes resources
echo "Deleting Kubernetes resources..."
kubectl delete deployment --all
kubectl delete service --all
kubectl delete pod --all

# Delete GKE clusters
echo "Deleting GKE clusters..."
gcloud container clusters delete jenkins-sonarqube-cluster --region us-west1-a --quiet
gcloud container clusters delete hadoop-cluster --region us-west1-a --quiet

# Delete VPC network and subnet
echo "Deleting VPC network and subnet..."
gcloud compute networks subnets delete gke-subnet --region us-west1 --quiet
gcloud compute networks delete gke-network --quiet

# Clean up Terraform state
echo "Cleaning up Terraform state..."
cd terraform
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
cd ..

echo "Cleanup complete!"