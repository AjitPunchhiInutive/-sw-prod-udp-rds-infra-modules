locals {
  deploy_jobs = { for k, v in var.jobs : k => v if v.deploy }
}

resource "random_id" "job_suffix" {
  for_each    = local.deploy_jobs
  byte_length = 4
}

resource "google_dataflow_flex_template_job" "main" {
  for_each = local.deploy_jobs
  provider = google-beta

  project = each.value.project_id
  region  = each.value.region
  name    = "${each.value.job_name}-${random_id.job_suffix[each.key].hex}"

  container_spec_gcs_path = each.value.container_spec_gcs_path

  machine_type     = each.value.machine_type
  num_workers      = each.value.num_workers
  max_workers      = each.value.max_workers
  staging_location = each.value.staging_location
  temp_location    = each.value.temp_location

  subnetwork            = each.value.subnetwork
  ip_configuration      = each.value.ip_configuration
  service_account_email = each.value.service_account_email

  enable_streaming_engine      = each.value.enable_streaming_engine
  skip_wait_on_job_termination = each.value.skip_wait_on_job_termination
  additional_experiments       = each.value.additional_experiments

  parameters = each.value.parameters
  labels     = each.value.labels
  on_delete  = each.value.on_delete
}
