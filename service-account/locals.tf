# =============================================================
# locals.tf — Computed Local Values
# =============================================================

locals {
  # Resolve Secret Manager project
  secret_project = (
    var.config.secret_manager_project_id != ""
    ? var.config.secret_manager_project_id
    : var.config.project_id
  )

  # Common labels merged with env/managed-by metadata
  common_labels = merge(
    {
      environment  = var.config.environment
      managed_by   = "terraform"
      project      = var.config.project_id
    },
    var.config.labels
  )

  # Flatten: one entry per (SA, role) pair for IAM bindings
  sa_role_pairs = flatten([
    for sa_key, sa in var.config.service_accounts : [
      for role in sa.iam_roles : {
        sa_key     = sa_key
        role       = role
        account_id = sa.account_id
      }
    ]
  ])

  # Filter only SAs that need a key AND have a secret_id
  sa_with_keys = {
    for k, v in var.config.service_accounts :
    k => v if v.create_key == true
  }

  sa_with_secrets = {
    for k, v in var.config.service_accounts :
    k => v if v.create_key == true && v.secret_id != null
  }
}
