resource "random_id" "job_suffix" {
  byte_length = 4
}

resource "google_dataflow_flex_template_job" "main" {
  provider = google-beta

  project = var.config.project_id
  region  = var.config.region
  name    = "${var.config.job_name}-${random_id.job_suffix.hex}"

  container_spec_gcs_path = var.config.container_spec_gcs_path

  machine_type = var.config.machine_type
  max_workers  = var.config.max_workers
  num_workers  = var.config.num_workers

  staging_location = var.config.staging_location
  temp_location    = var.config.temp_location

  subnetwork       = local.subnetwork
  ip_configuration = local.ip_configuration

  service_account_email = var.config.service_account_email

  enable_streaming_engine      = var.config.enable_streaming_engine
  skip_wait_on_job_termination = var.config.skip_wait_on_job_termination
  additional_experiments       = var.config.additional_experiments

  parameters = var.config.parameters
  labels     = local.common_labels
  on_delete  = var.config.on_delete
}
