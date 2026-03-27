# =============================================================
# main.tf — VPC Service Controls Module
# Section 1 — Access Policy (org-level, no scopes)
# Section 2 — Access Levels
# Section 3 — Service Perimeter (dry run or enforced)
# Section 4 — BigQuery Audit Log Dataset
# Section 5 — Log Sink → BigQuery
# =============================================================


# ─────────────────────────────────────────────────────────────
# SECTION 1: ACCESS CONTEXT MANAGER POLICY
# ─────────────────────────────────────────────────────────────
# IMPORTANT: GCP allows only ONE policy per organization.
# scopes intentionally omitted → org-level policy.
# Scoping to a project/folder prevents other projects from
# joining perimeters under this policy (Error 400).
#
# create_access_policy = false → set existing_policy_id in config
# create_access_policy = true  → requires accesscontextmanager.policies.create at org

resource "google_access_context_manager_access_policy" "policy" {
  count  = var.config.create_access_policy ? 1 : 0
  parent = "organizations/${var.config.org_id}"
  title  = var.config.access_policy_title
}


# ─────────────────────────────────────────────────────────────
# SECTION 2: ACCESS LEVELS
# ─────────────────────────────────────────────────────────────
# Defines trusted identities permitted to cross the perimeter.
# One resource per entry in config.access_levels.

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
# Supports multiple projects via local.perimeter_resources.
# No ingress/egress rules — access controlled via access levels only.
#
# use_explicit_dry_run_spec = true  → DRY_RUN  (violations logged, nothing blocked)
# use_explicit_dry_run_spec = false → ENFORCED (violations actively denied)

resource "google_access_context_manager_service_perimeter" "perimeter" {
  parent         = local.policy_name
  name           = "${local.policy_name}/servicePerimeters/${var.config.perimeter_name}"
  title          = var.config.perimeter_title
  description    = "${var.config.perimeter_description} | Mode: ${upper(local.perimeter_mode)}"
  perimeter_type = "PERIMETER_TYPE_REGULAR"

  use_explicit_dry_run_spec = var.config.dry_run

  # ── Enforced Spec ─────────────────────────────────────────
  # Always defined. Active when dry_run = false.
  status {
    resources           = local.perimeter_resources
    restricted_services = var.config.restricted_services
    access_levels       = local.access_level_names
  }

  # ── Dry Run Spec ──────────────────────────────────────────
  # Only rendered when dry_run = true.
  # Mirrors enforced spec — GCP logs violations, nothing blocked.
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


# ─────────────────────────────────────────────────────────────
# SECTION 4: BIGQUERY AUDIT LOG DATASET
# ─────────────────────────────────────────────────────────────
# Receives VPC SC violation logs from the log sink.
# Partitioned by date, auto-expires after configured period.

resource "google_bigquery_dataset" "audit" {
  dataset_id                      = var.config.bigquery.audit_dataset_id
  project                         = var.config.primary_project_id
  friendly_name                   = var.config.bigquery.audit_friendly_name
  description                     = var.config.bigquery.audit_description
  location                        = var.config.bigquery.location
  delete_contents_on_destroy      = var.config.bigquery.delete_contents_on_destroy
  default_table_expiration_ms     = var.config.bigquery.default_table_expiration_ms
  default_partition_expiration_ms = var.config.bigquery.partition_expiration_ms

  labels = local.common_labels

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  access {
    role          = "READER"
    special_group = "projectReaders"
  }
}


# ─────────────────────────────────────────────────────────────
# SECTION 5: LOG SINK → BIGQUERY AUDIT DATASET
# ─────────────────────────────────────────────────────────────

resource "google_logging_project_sink" "audit_sink" {
  name        = var.config.log_sink.name
  project     = var.config.primary_project_id
  description = var.config.log_sink.description
  destination = local.log_sink_destination
  filter      = var.config.log_sink.filter

  unique_writer_identity = true

  bigquery_options {
    use_partitioned_tables = true
  }

  depends_on = [google_bigquery_dataset.audit]
}

# Grant log sink writer SA dataEditor on the audit dataset
resource "google_bigquery_dataset_iam_member" "log_sink_writer" {
  project    = var.config.primary_project_id
  dataset_id = google_bigquery_dataset.audit.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.audit_sink.writer_identity

  depends_on = [
    google_bigquery_dataset.audit,
    google_logging_project_sink.audit_sink,
  ]
}
