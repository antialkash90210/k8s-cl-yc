#!/bin/bash

echo "=== Setting up Kubernetes cluster access ==="

# Save kubeconfig
echo "Saving kubeconfig..."
terraform output kubeconfig > kubeconfig.yaml

# Set KUBECONFIG
export KUBECONFIG=./kubeconfig.yaml

echo "=== Cluster information ==="
kubectl cluster-info

echo -e "\n=== Node information ==="
kubectl get nodes -o wide

echo -e "\n=== Getting node IP addresses for SSH ==="
echo "Using Yandex Cloud CLI:"
yc compute instance list --folder-id $(grep folder_id terraform.tfvars | cut -d'"' -f2) | grep --color=never -E "name|external_ip"

echo -e "\n=== SSH connection examples ==="
echo "ssh -i $(grep ssh_private_key_path terraform.tfvars | cut -d'"' -f2) ubuntu@<EXTERNAL_IP>"

echo -e "\n=== To use kubectl in future sessions ==="
echo "export KUBECONFIG=./kubeconfig.yaml"
