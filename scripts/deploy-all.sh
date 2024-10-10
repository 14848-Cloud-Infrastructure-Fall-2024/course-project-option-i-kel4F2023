#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get the current project ID from gcloud config
PROJECT_ID=$(gcloud config get-value project)

# Apply Terraform configuration
echo "Applying Terraform configuration..."
cd terraform
export TF_VAR_project_id=$PROJECT_ID
terraform init
terraform apply -auto-approve
cd ..

# Get cluster credentials
echo "Getting cluster credentials..."
gcloud container clusters get-credentials jenkins-sonarqube-cluster --region us-west1-a
gcloud container clusters get-credentials hadoop-cluster --region us-west1-a

# Deploy Jenkins and SonarQube
echo "Deploying Jenkins and SonarQube..."
kubectl apply -f k8s/jenkins/jenkins-deployment.yaml
kubectl apply -f k8s/sonarqube/sonarqube-deployment.yaml

# Set up Jenkins and SonarQube intercommunication
# echo "Setting up Jenkins and SonarQube intercommunication..."
# ./scripts/setup-jenkins-sonarqube.sh

# Deploy Hadoop
echo "Deploying Hadoop..."
kubectl apply -f k8s/hadoop/hadoop-master-deployment.yaml
kubectl apply -f k8s/hadoop/hadoop-worker-deployment.yaml

echo "Deployment complete!"