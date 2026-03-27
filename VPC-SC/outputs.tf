# =============================================================
# outputs.tf
# =============================================================

# ─── Access Policy ──────────────────────────────────────────
output "access_policy_name" {
  description = "Full resource name of the Access Context Manager policy."
  value       = local.policy_name
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

# ─── BigQuery ────────────────────────────────────────────────
output "audit_dataset_id" {
  description = "BigQuery dataset ID for VPC SC audit logs."
  value       = google_bigquery_dataset.audit.dataset_id
}

output "audit_dataset_self_link" {
  description = "Self-link of the BigQuery audit log dataset."
  value       = google_bigquery_dataset.audit.self_link
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
