locals {
  REGION_B = "${var.REGION}-b"
  REGION_C = "${var.REGION}-c"
}

resource "google_container_cluster" "primary" {
  name                     = "primary"
  location                 = local.REGION_B
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.main.self_link
  subnetwork               = google_compute_subnetwork.private.self_link
  #   logging_service          = "logging.googleapis.com/kubernetes" 
  #   monitoring_service       = "monitoring.googleapis.com/kubernetes"
  networking_mode = "VPC_NATIVE"

  # Optional, if you want multi-zonal cluster
  node_locations = [
    local.REGION_C
  ]

  addons_config {
    http_load_balancing {
      disabled = true
    }

    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = var.WORKLOAD_POOL
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false # true if want to use bastion host to access | false if want to access public
    master_ipv4_cidr_block  = var.MASTER_IPV4_CIDR_BLOCK
  }
}