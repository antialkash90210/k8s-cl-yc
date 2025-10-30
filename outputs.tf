output "cluster_id" {
  description = "Kubernetes cluster ID"
  value       = yandex_kubernetes_cluster.k8s-cluster.id
}

output "cluster_external_endpoint" {
  description = "Kubernetes cluster external endpoint"
  value       = yandex_kubernetes_cluster.k8s-cluster.master[0].external_v4_endpoint
}

output "cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate"
  value       = yandex_kubernetes_cluster.k8s-cluster.master[0].cluster_ca_certificate
  sensitive   = true
}

output "node_group_id" {
  description = "Kubernetes node group ID"
  value       = yandex_kubernetes_node_group.k8s-nodes.id
}

output "kubeconfig" {
  description = "Kubeconfig file content"
  value       = <<EOT
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${yandex_kubernetes_cluster.k8s-cluster.master[0].cluster_ca_certificate}
    server: ${yandex_kubernetes_cluster.k8s-cluster.master[0].external_v4_endpoint}
  name: yc-${var.cluster_name}
contexts:
- context:
    cluster: yc-${var.cluster_name}
    user: yc-${var.cluster_name}
  name: yc-${var.cluster_name}
current-context: yc-${var.cluster_name}
kind: Config
users:
- name: yc-${var.cluster_name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: yc
      args:
      - k8s
      - create-token
EOT
  sensitive = true
}

output "ssh_instructions" {
  description = "Instructions for SSH connection"
  value       = <<EOT
To connect to Kubernetes nodes via SSH:

1. Get the node external IP addresses using Yandex Cloud CLI:
   yc compute instance list --folder-id ${var.yandex_folder_id}

2. Look for instances with names starting with the node group name

3. Connect to any node using:
   ssh -i ${var.ssh_private_key_path} ubuntu@<NODE_EXTERNAL_IP>

4. After setting up kubeconfig, you can also get node information:
   kubectl get nodes -o wide
EOT
}

output "cluster_connection_commands" {
  description = "Commands to connect to the cluster"
  value       = <<EOT
Configure kubectl access:

1. Save kubeconfig:
   terraform output kubeconfig > kubeconfig.yaml

2. Set KUBECONFIG environment variable:
   export KUBECONFIG=./kubeconfig.yaml

3. Verify cluster connection:
   kubectl get nodes

4. Get node external IPs for SSH:
   kubectl get nodes -o wide
EOT
}
