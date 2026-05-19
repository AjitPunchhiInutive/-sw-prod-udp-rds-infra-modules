# =============================================================
# outputs.tf
# =============================================================

# ─── Access Policy ──────────────────────────────────────────
output "access_policy_name" {
  description = "Full resource name of the Access Context Manager policy."
  value       = local.policy_name
}

# ─── VPC SC ─────────────────────────────────────────────────
output "perimeter_name" {
  description = "Full resource name of the VPC SC perimeter."
  value       = google_access_context_manager_service_perimeter.perimeter.name
}

output "perimeter_mode" {
  description = "Current perimeter mode: DRY_RUN or ENFORCED."
  value       = local.perimeter_mode
}

output "restricted_services" {
  description = "GCP APIs restricted by the perimeter."
  value       = var.config.restricted_services
}

# ─── Storage ─────────────────────────────────────────────────
output "bucket_name" {
  description = "Name of the Cloud Storage bucket."
  value       = google_storage_bucket.bucket.name
}

output "bucket_url" {
  description = "gs:// URL of the bucket."
  value       = google_storage_bucket.bucket.url
}

# ─── BigQuery ────────────────────────────────────────────────
output "data_dataset_id" {
  description = "BigQuery dataset ID for workload data."
  value       = google_bigquery_dataset.data.dataset_id
}

output "audit_dataset_id" {
  description = "BigQuery dataset ID for audit logs."
  value       = google_bigquery_dataset.audit.dataset_id
}

# ─── Log Sink ────────────────────────────────────────────────
output "log_sink_name" {
  description = "Name of the project log sink."
  value       = google_logging_project_sink.audit_sink.name
}

output "log_sink_writer_identity" {
  description = "Auto-created writer SA — granted dataEditor on the audit dataset."
  value       = google_logging_project_sink.audit_sink.writer_identity
}

output "log_sink_destination" {
  description = "Full BigQuery destination URI for the log sink."
  value       = local.log_sink_destination
}
