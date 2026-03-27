
# ─── Access Policy ──────────────────────────────────────────
output "access_policy_name" {
  description = "Full resource name of the Access Context Manager policy."
  value       = local.policy_name
}

output "access_policy_id" {
  description = "Numeric ID of the created Access Policy."
  value       = var.config.create_access_policy ? google_access_context_manager_access_policy.policy[0].name : var.config.existing_policy_id
}

output "access_policy_folder_scope" {
  description = "Folder ID used to scope this Access Policy."
  value       = "folders/${var.config.folder_id}"
}

# ─── VPC Service Controls ───────────────────────────────────
output "perimeter_name" {
  description = "Full resource name of the VPC SC service perimeter."
  value       = google_access_context_manager_service_perimeter.perimeter.name
}

output "perimeter_mode" {
  description = "Current perimeter mode: dry_run (audit) or enforced (blocking)."
  value       = local.perimeter_mode
}

output "perimeter_resources" {
  description = "List of project resource paths included in the perimeter."
  value       = local.perimeter_resources
}

output "restricted_services_count" {
  description = "Number of services restricted by the perimeter."
  value       = length(var.config.restricted_services)
}

output "access_level_names" {
  description = "Full resource names of access levels bound to the perimeter."
  value       = local.access_level_names
}

# ─── GCS Log Storage ────────────────────────────────────────
output "vpc_sc_log_bucket_name" {
  description = "Name of the GCS bucket storing raw VPC SC audit logs."
  value       = google_storage_bucket.vpc_sc_logs.name
}

output "vpc_sc_log_bucket_url" {
  description = "gs:// URL of the VPC SC log storage bucket."
  value       = google_storage_bucket.vpc_sc_logs.url
}

# ─── BigQuery ────────────────────────────────────────────────
output "audit_dataset_id" {
  description = "BigQuery dataset ID for VPC SC audit logs."
  value       = google_bigquery_dataset.audit.dataset_id
}

output "audit_dataset_self_link" {
  description = "Self-link of the BigQuery audit log dataset."
  value       = google_bigquery_dataset.audit.self_link
}

# ─── Log Sink — BigQuery ─────────────────────────────────────
output "log_sink_bq_name" {
  description = "Name of the BigQuery log sink."
  value       = google_logging_project_sink.audit_sink_bq.name
}

output "log_sink_bq_writer_identity" {
  description = "Writer SA for BigQuery log sink — granted dataEditor on audit dataset."
  value       = google_logging_project_sink.audit_sink_bq.writer_identity
}

output "log_sink_bq_destination" {
  description = "Full BigQuery destination URI for the log sink."
  value       = local.log_sink_destination_bq
}

# ─── Log Sink — GCS ──────────────────────────────────────────
output "log_sink_gcs_name" {
  description = "Name of the GCS log sink."
  value       = google_logging_project_sink.audit_sink_gcs.name
}

output "log_sink_gcs_writer_identity" {
  description = "Writer SA for GCS log sink — granted objectCreator on log bucket."
  value       = google_logging_project_sink.audit_sink_gcs.writer_identity
}

output "log_sink_gcs_destination" {
  description = "Full GCS destination URI for the log sink."
  value       = local.log_sink_destination_gcs
}
