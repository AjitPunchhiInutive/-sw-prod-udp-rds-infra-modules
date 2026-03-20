# =============================================================
# locals.tf — YAML loader + computed values from var.config
# =============================================================

locals {

  # ─── Load YAML → feeds var.config via terraform.tfvars ─────
  # The YAML file is the source of truth. It is loaded here for
  # reference. The actual variable input comes from terraform.tfvars
  # which is generated from the YAML in CI/CD pipelines.
  sc_config_files = fileset("config/service-control", "*.yaml")
  _yaml_config    = yamldecode(file("config/service-control/${one(local.sc_config_files)}"))

  # ─── Access Policy Name ─────────────────────────────────────
  # Resolves full ACM policy path from either:
  #   - newly created policy (create_access_policy = true)
  #   - existing policy     (create_access_policy = false)
  policy_name = var.config.create_access_policy ? (
    "accessPolicies/${google_access_context_manager_access_policy.policy[0].name}"
  ) : (
    "accessPolicies/${var.config.existing_policy_id}"
  )

  # ─── Perimeter Mode ─────────────────────────────────────────
  # dry_run = true  → "DRY_RUN"  (audit only — nothing blocked)
  # dry_run = false → "ENFORCED" (violations actively denied)
  perimeter_mode = var.config.dry_run ? "dry_run" : "enforced"

  # ─── Perimeter Resources ────────────────────────────────────
  # GCP requires "projects/<project_number>" format
  perimeter_resources = [
    "projects/${var.config.project_number}"
  ]

  # ─── Access Levels Map ──────────────────────────────────────
  # Keyed by name — safe for for_each
  access_levels_map = {
    for al in var.config.access_levels : al.name => al
  }

  # ─── Access Level Full Resource Names ───────────────────────
  # Full path required when binding levels to the perimeter
  access_level_names = [
    for al in var.config.access_levels :
    "${local.policy_name}/accessLevels/${al.name}"
  ]

  # ─── Log Sink Destination ───────────────────────────────────
  # BigQuery destination URI format required by google_logging_project_sink
  log_sink_destination = "bigquery.googleapis.com/projects/${var.config.project_id}/datasets/${var.config.bigquery.audit_dataset_id}"

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
