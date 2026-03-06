output "secret_ids" {
  description = "Map of secret keys to their full GCP secret resource IDs"
  value       = { for k, v in google_secret_manager_secret.secrets : k => v.id }
}

output "secret_names" {
  description = "Map of secret keys to their secret_id names"
  value       = { for k, v in google_secret_manager_secret.secrets : k => v.secret_id }
}

output "secret_version_ids" {
  description = "Map of secret version keys to their full resource IDs"
  value       = { for k, v in google_secret_manager_secret_version.versions : k => v.id }
  sensitive   = true
}
