
resource "google_service_account" "sa" {
  for_each = local.sa_map

  project      = var.config.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
}

resource "google_service_account_key" "sa_key" {
  for_each = local.sa_map

  service_account_id = google_service_account.sa[each.key].name
  key_algorithm      = "KEY_ALG_RSA_2048"
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}


resource "google_secret_manager_secret_version" "sa_key_version" {
  for_each = local.sa_map

  secret      = "projects/${var.config.secret_manager_project_id}/secrets/${each.value.secret_id}"
  secret_data = base64decode(google_service_account_key.sa_key[each.key].private_key)

  depends_on = [google_service_account_key.sa_key]
}

resource "google_project_iam_member" "sa_roles" {
  for_each = local.sa_iam_bindings

  project = var.config.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.sa[each.value.account_id].email}"

  depends_on = [google_service_account.sa]
}
