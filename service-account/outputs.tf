output "service_accounts" {
  description = "Service account resources keyed by the map key in config.service_accounts."
  value       = google_service_account.sa
}