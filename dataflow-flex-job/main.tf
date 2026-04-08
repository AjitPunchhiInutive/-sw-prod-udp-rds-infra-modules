locals {
  ip_configuration = var.use_public_ips ? "WORKER_IP_PUBLIC" : "WORKER_IP_PRIVATE"
}

resource "random_id" "job_suffix" {
  byte_length = 4
}

resource "google_dataflow_flex_template_job" "main" {
  provider = google-beta

  project = var.project_id
  region  = var.region
  name    = "${var.name}-${random_id.job_suffix.hex}"

  container_spec_gcs_path = var.container_spec_gcs_path

  machine_type = var.machine_type
  max_workers  = var.max_workers
  num_workers  = var.num_workers

  staging_location = var.staging_location
  temp_location    = var.temp_location

  subnetwork       = var.subnetwork
  ip_configuration = local.ip_configuration

  service_account_email = var.service_account_email

  enable_streaming_engine      = var.enable_streaming_engine
  skip_wait_on_job_termination = var.skip_wait_on_job_termination
  additional_experiments       = var.additional_experiments

  parameters = var.parameters
  labels     = var.labels
  on_delete  = var.on_delete
}
