#!/bin/bash

echo "=== Destroying Kubernetes cluster ==="

# Check if we have state
if [ ! -f "terraform.tfstate" ]; then
    echo "No terraform state found. Cluster might already be destroyed."
    exit 1
fi

echo "The following resources will be destroyed:"
terraform plan -destroy

read -p "Are you sure you want to destroy the cluster? (yes/no): " confirmation

if [ "$confirmation" = "yes" ]; then
    echo "Destroying cluster..."
    terraform destroy -auto-approve
    echo "Cluster destruction completed."
    
    # Clean up local files
    echo "Cleaning up local files..."
    rm -f kubeconfig.yaml
    echo "Cleanup completed."
else
    echo "Destruction cancelled."
fi
