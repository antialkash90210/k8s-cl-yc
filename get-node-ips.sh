#!/bin/bash

echo "=== Getting Kubernetes node information ==="

# Get kubeconfig
terraform output kubeconfig > kubeconfig.yaml
export KUBECONFIG=./kubeconfig.yaml

echo "=== Node information from Kubernetes ==="
kubectl get nodes -o wide

echo -e "\n=== Node information from Yandex Cloud ==="
yc compute instance list --folder-id $(grep folder_id terraform.tfvars | cut -d'"' -f2)

echo -e "\n=== SSH connection example ==="
echo "ssh -i ~/.ssh/id_rsa ubuntu@<EXTERNAL_IP_FROM_ABOVE>"
