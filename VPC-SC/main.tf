resource "google_access_context_manager_access_policy" "policy" {
  count  = var.config.create_access_policy ? 1 : 0

  # Policy always lives under the organization
  parent = "organizations/${var.config.org_id}"
  title  = var.config.access_policy_title
  scopes = ["folders/${var.config.folder_id}"]
}

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

resource "google_access_context_manager_service_perimeter" "perimeter" {
  parent         = local.policy_name
  name           = "${local.policy_name}/servicePerimeters/${var.config.perimeter_name}"
  title          = var.config.perimeter_title
  description    = "${var.config.perimeter_description} | Mode: ${upper(local.perimeter_mode)}"
  perimeter_type = "PERIMETER_TYPE_REGULAR"

  use_explicit_dry_run_spec = var.config.dry_run
  status {
    resources           = local.perimeter_resources
    restricted_services = var.config.restricted_services
    access_levels       = local.access_level_names
  }
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
resource "google_storage_bucket" "vpc_sc_logs" {
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
      age = var.config.storage.log_retention_days
    }
  }

  labels = local.common_labels
}

resource "google_storage_bucket_iam_member" "gcs_sink_writer" {
  bucket = google_storage_bucket.vpc_sc_logs.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.audit_sink_gcs.writer_identity

  depends_on = [
    google_storage_bucket.vpc_sc_logs,
    google_logging_project_sink.audit_sink_gcs,
  ]
}
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

resource "google_logging_project_sink" "audit_sink_bq" {
  name        = var.config.log_sink.name
  project     = var.config.primary_project_id
  description = var.config.log_sink.description
  destination = local.log_sink_destination_bq
  filter      = var.config.log_sink.filter

  unique_writer_identity = true

  bigquery_options {
    use_partitioned_tables = true
  }

  depends_on = [google_bigquery_dataset.audit]
}

resource "google_bigquery_dataset_iam_member" "bq_sink_writer" {
  project    = var.config.primary_project_id
  dataset_id = google_bigquery_dataset.audit.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.audit_sink_bq.writer_identity

  depends_on = [
    google_bigquery_dataset.audit,
    google_logging_project_sink.audit_sink_bq,
  ]
}
resource "google_logging_project_sink" "audit_sink_gcs" {
  name        = var.config.log_sink_gcs.name
  project     = var.config.primary_project_id
  description = var.config.log_sink_gcs.description
  destination = local.log_sink_destination_gcs
  filter      = var.config.log_sink_gcs.filter

  unique_writer_identity = true

  depends_on = [google_storage_bucket.vpc_sc_logs]
}
