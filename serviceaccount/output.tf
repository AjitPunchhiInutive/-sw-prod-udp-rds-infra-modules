
output "service_account_emails" {
  description = "Email addresses of all created service accounts"
  value = {
    for k, sa in google_service_account.sa : k => sa.email
  }
}

output "service_account_unique_ids" {
  description = "Unique numeric IDs of all created service accounts"
  value = {
    for k, sa in google_service_account.sa : k => sa.unique_id
  }
}

output "service_account_key_names" {
  description = "Full resource names of the generated service account keys"
  value = {
    for k, key in google_service_account_key.sa_key : k => key.name
  }
}

output "service_account_key_expiry" {
  description = "Expiry timestamps of the generated keys (empty if no expiry)"
  value = {
    for k, key in google_service_account_key.sa_key : k => key.valid_before
  }
}


output "secret_version_names" {
  description = "Full resource names of the Secret Manager versions storing each key"
  value = {
    for k, sv in google_secret_manager_secret_version.sa_key_version : k => sv.name
  }
}

output "secret_version_ids" {
  description = "Version IDs within each Secret Manager secret"
  value = {
    for k, sv in google_secret_manager_secret_version.sa_key_version : k => sv.version
  }
}
