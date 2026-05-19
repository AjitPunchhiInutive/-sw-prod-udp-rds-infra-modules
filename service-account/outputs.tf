# =============================================================
# outputs.tf — Outputs
# =============================================================

output "service_account_emails" {
  description = "Map of logical name → service account email."
  value = {
    for k, sa in google_service_account.sa :
    k => sa.email
  }
}

output "service_account_names" {
  description = "Map of logical name → fully-qualified SA resource name."
  value = {
    for k, sa in google_service_account.sa :
    k => sa.name
  }
}

output "service_account_unique_ids" {
  description = "Map of logical name → SA unique ID (useful for Workload Identity bindings)."
  value = {
    for k, sa in google_service_account.sa :
    k => sa.unique_id
  }
}

output "sa_key_ids" {
  description = "Map of logical name → SA key ID (non-sensitive key identifier)."
  sensitive   = false
  value = {
    for k, key in google_service_account_key.sa_key :
    k => key.id
  }
}

output "secret_version_names" {
  description = "Map of logical name → full Secret Manager version resource name."
  value = {
    for k, ver in google_secret_manager_secret_version.sa_key_version :
    k => ver.name
  }
}

output "secret_version_numbers" {
  description = "Map of logical name → version number of the stored SA key."
  value = {
    for k, ver in google_secret_manager_secret_version.sa_key_version :
    k => ver.version
  }
}
