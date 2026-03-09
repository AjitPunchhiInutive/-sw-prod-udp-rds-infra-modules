# ------- Service Accounts -------------------------------------

resource "google_service_account" "sa" {
  for_each = var.config.service_accounts

  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
  project      = var.config.project_id
}

# ------- Service Account Keys ---------------------------------
# Keys are only created when create_key = true.
# PRODUCTION NOTE: Prefer Workload Identity Federation over SA keys
# wherever possible. Keys should only be used when WIF is not supported.

resource "google_service_account_key" "sa_key" {
  for_each = local.sa_with_keys

  service_account_id = google_service_account.sa[each.key].name
  public_key_type    = "TYPE_X509_PEM_FILE"
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"

  depends_on = [google_service_account.sa]
}

# ------- Fetch Existing Secrets --------------------------------
# Reference existing secrets in Secret Manager by their ID.

data "google_secret_manager_secret" "existing" {
  for_each = local.sa_with_secrets

  project   = local.secret_project
  secret_id = each.value.secret_id
}

# ------- Add SA Key as New Secret Version ----------------------
# Each apply creates a NEW version. Old versions are NOT destroyed
# automatically — manage version lifecycle via Secret Manager policies.

resource "google_secret_manager_secret_version" "sa_key_version" {
  for_each = local.sa_with_secrets

  secret      = data.google_secret_manager_secret.existing[each.key].id
  secret_data = base64decode(google_service_account_key.sa_key[each.key].private_key)

  # Prevent accidental deletion of secret versions in prod
  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_service_account_key.sa_key]
}

# ------- Grant Secret Accessor to the SA itself ----------------
# The SA can read its own key from Secret Manager if needed
# (e.g., for bootstrapping or rotation workflows).

resource "google_secret_manager_secret_iam_member" "sa_secret_accessor" {
  for_each = local.sa_with_secrets

  project   = local.secret_project
  secret_id = data.google_secret_manager_secret.existing[each.key].secret_id
  role      = "roles/secretmanager.secretVersionManager"
  member    = "serviceAccount:${google_service_account.sa[each.key].email}"
}
resource "google_project_iam_member" "sa_project_roles" {
  for_each = {
    for pair in local.sa_role_pairs :
    "${pair.sa_key}__${pair.role}" => pair
  }

  project = var.config.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.sa[each.value.sa_key].email}"

  depends_on = [google_service_account.sa]
}