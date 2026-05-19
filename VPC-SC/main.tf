resource "google_access_context_manager_access_policy" "policy" {
  count  = var.config.create_access_policy ? 1 : 0
  parent = "organizations/${var.config.org_id}"
  title  = var.config.access_policy_title
  scopes = local.primary_folder_id != null ? ["folders/${local.primary_folder_id}"] : []
}


# ─────────────────────────────────────────────────────────────
# SECTION 2: ACCESS LEVELS
# ─────────────────────────────────────────────────────────────

resource "google_access_context_manager_access_level" "levels" {
  for_each = local.access_levels_map

  parent = local.policy_name
  name   = "${local.policy_name}/accessLevels/${each.key}"
  title  = each.key

  basic {
    conditions {
      members = each.value.members
    }
  }

  depends_on = [google_access_context_manager_access_policy.policy]
}


# ─────────────────────────────────────────────────────────────
# SECTION 3: VPC SERVICE PERIMETER
# ─────────────────────────────────────────────────────────────

resource "google_access_context_manager_service_perimeter" "perimeter" {
  parent         = local.policy_name
  name           = "${local.policy_name}/servicePerimeters/${var.config.perimeter_name}"
  title          = var.config.perimeter_title
  description    = "${var.config.perimeter_description} | Mode: ${upper(local.perimeter_mode)}"
  perimeter_type = "PERIMETER_TYPE_REGULAR"

  use_explicit_dry_run_spec = var.config.dry_run

  # ── Enforced Spec ──────────────────────────────────────────
  # dry_run = true  → empty (no projects in enforced mode)
  # dry_run = false → full (projects actively enforced)
  status {
    resources           = var.config.dry_run ? [] : local.perimeter_resources
    restricted_services = var.config.dry_run ? [] : var.config.restricted_services
    access_levels       = var.config.dry_run ? [] : local.access_level_names
  }

  # ── Dry Run Spec (only rendered when dry_run = true) ───────
  dynamic "spec" {
    for_each = var.config.dry_run ? [1] : []
    content {
      resources           = local.perimeter_resources
      restricted_services = var.config.restricted_services
      access_levels       = local.access_level_names
    }
  }

  depends_on = [google_access_context_manager_access_level.levels]
}
