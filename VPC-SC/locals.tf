locals {
  policy_name = var.config.create_access_policy ? (
    "accessPolicies/${google_access_context_manager_access_policy.policy[0].name}"
  ) : (
    "accessPolicies/${var.config.existing_policy_id}"
  )
  perimeter_mode = var.config.dry_run ? "dry_run" : "enforced"
  perimeter_resources = [
    for p in var.config.projects : "projects/${p.project_number}"
  ]
  access_levels_map = {
    for al in var.config.access_levels : al.name => al
  }
  access_level_names = [
    for al in var.config.access_levels :
    "${local.policy_name}/accessLevels/${al.name}"
  ]
  log_sink_destination_bq = "bigquery.googleapis.com/projects/${var.config.primary_project_id}/datasets/${var.config.bigquery.audit_dataset_id}"

   log_sink_destination_gcs = "storage.googleapis.com/${var.config.storage.bucket_name}"
  common_labels = merge(
    {
      managed_by     = "terraform"
      environment    = lower(lookup(var.config.labels, "environment", "prod"))
      perimeter_mode = local.perimeter_mode
    },
    var.config.labels
  )
}
