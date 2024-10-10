#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null
then
    echo "gcloud could not be found. Please install the Google Cloud SDK."
    exit 1
fi

# Prompt for project ID
read -p "Enter your GCP Project ID: " PROJECT_ID

# Set the project
gcloud config set project $PROJECT_ID

# Authenticate with GCP
gcloud auth login

# Enable necessary APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com

# Create a service account for Terraform
SA_NAME="terraform-sa"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud iam service-accounts create $SA_NAME --display-name "Terraform Service Account"

# Grant necessary permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/container.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/compute.admin"

# Create and download the key
gcloud iam service-accounts keys create gcp-credentials.json --iam-account=${SA_EMAIL}

echo "GCP setup complete. Please keep gcp-credentials.json safe and do not commit it to your repository."