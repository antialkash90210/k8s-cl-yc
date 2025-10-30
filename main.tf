terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.95"
    }
  }
  required_version = ">= 1.0"
}

provider "yandex" {
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  token     = var.yandex_token
  zone      = var.zone
}

# Создание сервисного аккаунта для Kubernetes
resource "yandex_iam_service_account" "k8s-admin" {
  name        = "k8s-admin"
  description = "Service account for Kubernetes cluster administration"
}

# Назначение ролей сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "k8s-admin-roles" {
  for_each = toset([
    "editor",
    "container-registry.images.puller",
    "container-registry.images.pusher"
  ])
  
  folder_id = var.yandex_folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.k8s-admin.id}"
}

# Создание сервисного аккаунта для нод
resource "yandex_iam_service_account" "k8s-nodes" {
  name        = "k8s-nodes"
  description = "Service account for Kubernetes nodes"
}

# Назначение ролей сервисному аккаунту нод
resource "yandex_resourcemanager_folder_iam_member" "k8s-nodes-roles" {
  for_each = toset([
    "container-registry.images.puller"
  ])
  
  folder_id = var.yandex_folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.k8s-nodes.id}"
}

# Создание сети
resource "yandex_vpc_network" "k8s-network" {
  name = "k8s-network"
}

# Создание подсети
resource "yandex_vpc_subnet" "k8s-subnet" {
  name           = "k8s-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["10.130.0.0/24"]
}

# Создание Kubernetes кластера
resource "yandex_kubernetes_cluster" "k8s-cluster" {
  name        = var.cluster_name
  description = "Kubernetes cluster with ${var.node_count} nodes"
  network_id  = yandex_vpc_network.k8s-network.id
  release_channel = "RAPID"  # Используем Rapid канал для актуальных версий

  master {
    version   = var.k8s_version
    public_ip = true

    zonal {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.k8s-subnet.id
    }

    maintenance_policy {
      auto_upgrade = true
      
      maintenance_window {
        start_time = "03:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = yandex_iam_service_account.k8s-admin.id
  node_service_account_id = yandex_iam_service_account.k8s-nodes.id

  kms_provider {
    key_id = yandex_kms_symmetric_key.k8s-key.id
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-admin-roles,
    yandex_resourcemanager_folder_iam_member.k8s-nodes-roles
  ]
}

# Создание KMS ключа для шифрования данных кластера
resource "yandex_kms_symmetric_key" "k8s-key" {
  name              = "k8s-secret-key"
  description       = "KMS key for Kubernetes secrets"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 year
}

# Назначение прав сервисному аккаунту на использование KMS ключа
resource "yandex_kms_symmetric_key_iam_binding" "k8s-kms-binding" {
  symmetric_key_id = yandex_kms_symmetric_key.k8s-key.id
  role             = "kms.keys.encrypterDecrypter"

  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-admin.id}",
  ]
}

# Создание группы нод
resource "yandex_kubernetes_node_group" "k8s-nodes" {
  cluster_id = yandex_kubernetes_cluster.k8s-cluster.id
  name       = "k8s-workers"
  version    = var.k8s_version

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.k8s-subnet.id]
    }

    resources {
      memory = var.node_memory
      cores  = var.node_cores
    }

    boot_disk {
      type = "network-ssd"
      size = var.node_disk_size
    }

    scheduling_policy {
      preemptible = false
    }

    metadata = {
      ssh-keys = "ubuntu:${file(var.ssh_public_key)}"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.node_count
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
    
    maintenance_window {
      day        = "monday"
      start_time = "22:00"
      duration   = "3h"
    }
  }

  depends_on = [
    yandex_kubernetes_cluster.k8s-cluster
  ]
}

# Создание правил безопасности
resource "yandex_vpc_security_group" "k8s-sg" {
  name        = "k8s-security-group"
  description = "Security group for Kubernetes cluster"
  network_id  = yandex_vpc_network.k8s-network.id

  ingress {
    protocol       = "TCP"
    description    = "SSH access"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "NodePort services"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }

  ingress {
    protocol       = "TCP"
    description    = "Kubelet API"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10250
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
