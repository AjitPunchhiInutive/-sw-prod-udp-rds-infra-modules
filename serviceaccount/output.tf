
output "sa_with_key_emails" {
  description = "Email addresses of service accounts created WITH a key"
  value = {
    for k, sa in google_service_account.with_key : k => sa.email
  }
}

output "sa_with_key_ids" {
  description = "Unique IDs of service accounts created WITH a key"
  value = {
    for k, sa in google_service_account.with_key : k => sa.unique_id
  }
}

output "sa_key_names" {
  description = "Resource names of the generated service account keys"
  value = {
    for k, key in google_service_account_key.sa_key : k => key.name
  }
}

output "secret_version_names" {
  description = "Full resource names of the Secret Manager versions where keys are stored"
  value = {
    for k, sv in google_secret_manager_secret_version.sa_key_version : k => sv.name
  }
}


output "sa_without_key_emails" {
  description = "Email addresses of service accounts created WITHOUT a key"
  value = {
    for k, sa in google_service_account.without_key : k => sa.email
  }
}

output "sa_without_key_ids" {
  description = "Unique IDs of service accounts created WITHOUT a key"
  value = {
    for k, sa in google_service_account.without_key : k => sa.unique_id
  }
}
