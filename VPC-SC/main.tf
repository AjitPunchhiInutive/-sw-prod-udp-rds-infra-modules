# =============================================================
# main.tf
# Section 1 — Access Policy (create or use existing)
# Section 2 — VPC Service Controls + Access Levels
# Section 3 — Cloud Storage Bucket
# Section 4 — BigQuery Datasets (data + audit)
# Section 5 — Log Sink → BigQuery Audit Dataset
# =============================================================


# ─────────────────────────────────────────────────────────────
# SECTION 1: ACCESS CONTEXT MANAGER POLICY
# ─────────────────────────────────────────────────────────────
# Only created when var.config.create_access_policy = true.
# Requires accesscontextmanager.policies.create at org level.
# Set to false and provide existing_policy_id to reuse.

resource "google_access_context_manager_access_policy" "policy" {
  count = var.config.create_access_policy ? 1 : 0

  parent = "organizations/${var.config.org_id}"
  title  = var.config.access_policy_title

  # Scope to all projects in the perimeter
  scopes = ["projects/${var.config.primary_project_number}"]
}


# ─────────────────────────────────────────────────────────────
# SECTION 2: VPC SERVICE CONTROLS
# ─────────────────────────────────────────────────────────────

# --- Access Levels -------------------------------------------
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

# --- Service Perimeter ---------------------------------------
# use_explicit_dry_run_spec = true  → DRY_RUN  (audit, no blocking)
# use_explicit_dry_run_spec = false → ENFORCED (violations blocked)
# perimeter_resources includes ALL projects from var.config.projects

resource "google_access_context_manager_service_perimeter" "perimeter" {
  parent         = local.policy_name
  name           = "${local.policy_name}/servicePerimeters/${var.config.perimeter_name}"
  title          = var.config.perimeter_title
  description    = "${var.config.perimeter_description} | Mode: ${local.perimeter_mode}"
  perimeter_type = "PERIMETER_TYPE_REGULAR"

  use_explicit_dry_run_spec = var.config.dry_run

  # ── Enforced Spec ─────────────────────────────────────────
  # Active when dry_run = false
  status {
    resources           = local.perimeter_resources
    restricted_services = var.config.restricted_services
    access_levels       = local.access_level_names
  }

  # ── Dry Run Spec ──────────────────────────────────────────
  # Only rendered when dry_run = true — logs violations, blocks nothing
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
# SECTION 3: CLOUD STORAGE BUCKET
# ─────────────────────────────────────────────────────────────
# Created in primary_project_id
# uniform_bucket_level_access required inside VPC SC perimeter

resource "google_storage_bucket" "bucket" {
  name          = var.config.storage.bucket_name
  project       = var.config.primary_project_id
  location      = var.config.storage.location
  storage_class = var.config.storage.storage_class
  force_destroy = var.config.storage.force_destroy

  uniform_bucket_level_access = true

  versioning {
    enabled = var.config.storage.versioning_enabled
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.config.storage.lifecycle_delete_age_days
    }
  }

  labels = local.common_labels
}


# ─────────────────────────────────────────────────────────────
# SECTION 4: BIGQUERY DATASETS
# ─────────────────────────────────────────────────────────────
# Both datasets created in primary_project_id

# --- Data Dataset (workload) ---------------------------------
resource "google_bigquery_dataset" "data" {
  dataset_id    = var.config.bigquery.data_dataset_id
  project       = var.config.primary_project_id
  friendly_name = var.config.bigquery.data_friendly_name
  description   = var.config.bigquery.data_description
  location      = var.config.bigquery.location

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

# --- Audit Dataset (log sink destination) --------------------
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

# --- Project Log Sink ----------------------------------------
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

# --- Grant Sink Writer access to Audit Dataset ---------------
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
