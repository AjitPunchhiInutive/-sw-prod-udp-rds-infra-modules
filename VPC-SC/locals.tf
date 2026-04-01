
locals {

  primary_folder_id = length(var.config.folder_ids) > 0 ? var.config.folder_ids[0] : null

  # ─── All Folder Paths ───────────────────────────────────────
  all_folder_paths = [
    for f in var.config.folder_ids : "folders/${f}"
  ]

  # ─── Access Policy Name ─────────────────────────────────────
  policy_name = var.config.create_access_policy ? (
    "accessPolicies/${google_access_context_manager_access_policy.policy[0].name}"
  ) : (
    "accessPolicies/${var.config.existing_policy_id}"
  )

  # ─── Perimeter Mode ─────────────────────────────────────────
  perimeter_mode = var.config.dry_run ? "dry_run" : "enforced"

  # ─── Perimeter Resources ────────────────────────────────────
  perimeter_resources = [
    for p in var.config.projects : "projects/${p.project_number}"
  ]

  # ─── Access Levels ──────────────────────────────────────────
  access_levels_map = {
    for al in var.config.access_levels : al.name => al
  }

  access_level_names = [
    for al in var.config.access_levels :
    "${local.policy_name}/accessLevels/${al.name}"
  ]

  # ─── Common Labels ──────────────────────────────────────────
  common_labels = merge(
    {
      managed_by     = "terraform"
      environment    = lower(lookup(var.config.labels, "environment", "prod"))
      perimeter_mode = local.perimeter_mode
    },
    var.config.labels
  )
}
