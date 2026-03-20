# =============================================================
# locals.tf — VPC SC Computed Local Values
# =============================================================

locals {

  # ─── Access Policy ──────────────────────────────────────────
  # Full resource path required by all ACM resources
  policy_name = "accessPolicies/${var.config.policy_id}"

  # ─── Perimeter Mode ─────────────────────────────────────────
  # dry_run = true  → "DRY_RUN"  (audit, no blocking)
  # dry_run = false → "ENFORCED" (active blocking)
  perimeter_mode = var.config.dry_run ? "DRY_RUN" : "ENFORCED"

  # ─── Perimeter Resources ────────────────────────────────────
  # GCP requires "projects/<project_number>" format
  perimeter_resources = [
    "projects/${var.config.project_number}"
  ]

  # ─── Access Level Full Resource Names ───────────────────────
  # Required format when binding access levels to a perimeter
  access_level_names = [
    for al in var.config.access_levels :
    "${local.policy_name}/accessLevels/${al.name}"
  ]

  # ─── Access Levels Map ──────────────────────────────────────
  # Keyed by name — safe for for_each on google_access_context_manager_access_level
  access_levels_map = {
    for al in var.config.access_levels : al.name => al
  }

  # ─── Log Sink Destination ───────────────────────────────────
  # BigQuery destination URI format required by google_logging_project_sink
  log_sink_destination = "bigquery.googleapis.com/projects/${var.config.project_id}/datasets/${var.config.bigquery.dataset_id}"

  # ─── Common Labels ──────────────────────────────────────────
  common_labels = merge(
    {
      managed_by     = "terraform"
      environment    = lookup(var.config.labels, "environment", "prod")
      perimeter_mode = local.perimeter_mode
    },
    var.config.labels
  )
}
