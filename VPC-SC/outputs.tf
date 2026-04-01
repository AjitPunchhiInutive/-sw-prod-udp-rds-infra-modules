output "access_policy_name" {
  description = "Full resource name of the Access Context Manager policy."
  value       = local.policy_name
}

output "access_policy_id" {
  description = "Numeric ID of the Access Policy."
  value       = var.config.create_access_policy ? google_access_context_manager_access_policy.policy[0].name : var.config.existing_policy_id
}

output "access_policy_primary_scope" {
  description = "Primary folder scope applied to the Access Policy. Null if org-level."
  value       = local.primary_folder_id != null ? "folders/${local.primary_folder_id}" : null
}

output "all_folder_ids" {
  description = "All folder paths provided in folder_ids."
  value       = local.all_folder_paths
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
