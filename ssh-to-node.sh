#!/bin/bash

# Get folder_id from terraform.tfvars
FOLDER_ID=$(grep folder_id terraform.tfvars | cut -d'"' -f2)
SSH_KEY=$(grep ssh_private_key_path terraform.tfvars | cut -d'"' -f2)

if [ -z "$1" ]; then
    echo "Usage: $0 <node_external_ip>"
    echo ""
    echo "Available nodes:"
    yc compute instance list --folder-id $FOLDER_ID --format json | jq -r '.[] | select(.name | startswith("ip-")) | "\(.name): \(.network_interfaces[0].primary_v4_address.one_to_one_nat.address)"'
    exit 1
fi

NODE_IP=$1
echo "Connecting to node at $NODE_IP..."
ssh -i $SSH_KEY ubuntu@$NODE_IP
