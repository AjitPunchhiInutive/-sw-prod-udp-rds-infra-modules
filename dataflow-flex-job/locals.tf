locals {
  common_labels = merge(
    {
      environment = var.config.environment
      managed_by  = "terraform"
    },
    var.config.labels
  )

  ip_configuration = var.config.use_public_ips ? "WORKER_IP_PUBLIC" : "WORKER_IP_PRIVATE"
  subnetwork       = var.config.subnetwork != "" ? var.config.subnetwork : null
}
