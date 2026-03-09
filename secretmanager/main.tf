# ─────────────────────────────────────────────────────────────────────────────
# GCP Secret Manager — Terraform
# ─────────────────────────────────────────────────────────────────────────────

# ── Secrets ──────────────────────────────────────────────────────────────────
resource "google_secret_manager_secret" "secrets" {
  for_each = local.secrets

  project   = each.value.project_id
  secret_id = each.value.secret_id
  labels    = each.value.labels

  # ttl is a plain attribute — NOT a block
  ttl = each.value.ttl

  annotations = each.value.annotations

  replication {
    dynamic "auto" {
      for_each = each.value.replication_type == "auto" ? [1] : []
      content {
        dynamic "customer_managed_encryption" {
          for_each = each.value.kms_key_name != null ? [1] : []
          content {
            kms_key_name = each.value.kms_key_name
          }
        }
      }
    }

    dynamic "user_managed" {
      for_each = each.value.replication_type == "user_managed" ? [1] : []
      content {
        dynamic "replicas" {
          for_each = each.value.replication_locations
          content {
            location = replicas.value
            dynamic "customer_managed_encryption" {
              for_each = each.value.kms_key_name != null ? [1] : []
              content {
                kms_key_name = each.value.kms_key_name
              }
            }
          }
        }
      }
    }
  }

  # Rotation policy (optional)
#   dynamic "rotation" {
#     for_each = each.value.rotation_period != null ? [1] : []
#     content {
#       rotation_period    = each.value.rotation_period
#       next_rotation_time = each.value.next_rotation_time
#     }
#   }

  # Pub/Sub topics for rotation notifications
#   dynamic "topics" {
#     for_each = each.value.topics
#     content {
#       name = topics.value
#     }
#   }
}

# ── Secret Versions ───────────────────────────────────────────────────────────
resource "google_secret_manager_secret_version" "versions" {
  for_each = local.secret_versions

  secret      = google_secret_manager_secret.secrets[each.value.secret_key].id
  secret_data = each.value.secret_data
  enabled     = each.value.enabled

  depends_on = [google_secret_manager_secret.secrets]
}

# ── Secret IAM Bindings ───────────────────────────────────────────────────────
resource "google_secret_manager_secret_iam_member" "bindings" {
  for_each = local.secret_iam_bindings

  project   = each.value.project_id
  secret_id = google_secret_manager_secret.secrets[each.value.secret_key].secret_id
  role      = each.value.role
  member    = each.value.member

  depends_on = [google_secret_manager_secret.secrets]
}
