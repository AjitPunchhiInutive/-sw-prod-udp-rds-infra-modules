resource "google_service_account" "with_key" {
  for_each = local.sa_with_key_map

  project      = var.config.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
}

resource "google_service_account_key" "sa_key" {
  for_each = local.sa_with_key_map

  service_account_id = google_service_account.with_key[each.key].name
  key_algorithm      = "KEY_ALG_RSA_2048"
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

resource "google_secret_manager_secret_version" "sa_key_version" {
  for_each = local.sa_with_key_map

  # Reference the existing secret in the other project
  secret = "projects/${var.config.secret_manager_project_id}/secrets/${each.value.secret_id}"

  # The key is base64-encoded by Terraform; decode it before storing
  secret_data = base64decode(google_service_account_key.sa_key[each.key].private_key)

  depends_on = [google_service_account_key.sa_key]
}


resource "google_project_iam_member" "with_key_roles" {
  for_each = local.sa_with_key_iam_bindings

  project = var.config.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.with_key[each.value.account_id].email}"

  depends_on = [google_service_account.with_key]
}

resource "google_service_account" "without_key" {
  for_each = local.sa_without_key_map

  project      = var.config.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
}


resource "google_project_iam_member" "without_key_roles" {
  for_each = local.sa_without_key_iam_bindings

  project = var.config.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.without_key[each.value.account_id].email}"

  depends_on = [google_service_account.without_key]
}
