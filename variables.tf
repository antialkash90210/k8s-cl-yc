variable "yandex_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yandex_folder_id" {
  description = "Yandex Folder ID"
  type        = string
}

variable "yandex_token" {
  description = "Yandex OAuth token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for node access"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "my-k8s-cluster"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "zone" {
  description = "Yandex Cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"  # Обновлено до актуальной версии
}

variable "node_disk_size" {
  description = "Node disk size in GB"
  type        = number
  default     = 64
}

variable "node_memory" {
  description = "Node memory in GB"
  type        = number
  default     = 4
}

variable "node_cores" {
  description = "Node CPU cores"
  type        = number
  default     = 2
}
