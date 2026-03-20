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
}
resource "google_access_context_manager_service_perimeter" "perimeter" {
  parent        = local.policy_name
  name          = "${local.policy_name}/servicePerimeters/${var.config.perimeter_name}"
  title         = var.config.perimeter_title
  description   = "${var.config.perimeter_description} | Mode: ${local.perimeter_mode}"
  perimeter_type = "PERIMETER_TYPE_REGULAR"
  use_explicit_dry_run_spec = var.config.dry_run
  status {
    resources           = local.perimeter_resources
    restricted_services = var.config.restricted_services
    access_levels       = local.access_level_names

    dynamic "ingress_policies" {
      for_each = local.ingress_policies
      content {
        ingress_from {
          identity_type = ingress_policies.value.ingress_from.identity_type
          dynamic "identities" {
            for_each = ingress_policies.value.ingress_from.identities
            content { identity = identities.value }
          }
          dynamic "sources" {
            for_each = ingress_policies.value.ingress_from.sources
            content { ip_subnetwork = sources.value.ip_subnetwork }
          }
        }
        ingress_to {
          resources = ingress_policies.value.ingress_to.resources
          dynamic "operations" {
            for_each = ingress_policies.value.ingress_to.operations
            content {
              service_name = operations.value.service_name
              dynamic "method_selectors" {
                for_each = operations.value.method_selectors
                content { method = method_selectors.value.method }
              }
            }
          }
        }
      }
    }

    dynamic "egress_policies" {
      for_each = local.egress_policies
      content {
        egress_from {
          identity_type = egress_policies.value.egress_from.identity_type
          dynamic "identities" {
            for_each = egress_policies.value.egress_from.identities
            content { identity = identities.value }
          }
        }
        egress_to {
          resources = egress_policies.value.egress_to.resources
          dynamic "operations" {
            for_each = egress_policies.value.egress_to.operations
            content {
              service_name = operations.value.service_name
              dynamic "method_selectors" {
                for_each = operations.value.method_selectors
                content { method = method_selectors.value.method }
              }
            }
          }
        }
      }
    }
  }

  dynamic "spec" {
    for_each = var.config.dry_run ? [1] : []
    content {
      resources           = local.perimeter_resources
      restricted_services = var.config.restricted_services
      access_levels       = local.access_level_names

      dynamic "ingress_policies" {
        for_each = local.ingress_policies
        content {
          ingress_from {
            identity_type = ingress_policies.value.ingress_from.identity_type
            dynamic "identities" {
              for_each = ingress_policies.value.ingress_from.identities
              content { identity = identities.value }
            }
          }
          ingress_to {
            resources = ingress_policies.value.ingress_to.resources
            dynamic "operations" {
              for_each = ingress_policies.value.ingress_to.operations
              content {
                service_name = operations.value.service_name
                dynamic "method_selectors" {
                  for_each = operations.value.method_selectors
                  content { method = method_selectors.value.method }
                }
              }
            }
          }
        }
      }

      dynamic "egress_policies" {
        for_each = local.egress_policies
        content {
          egress_from {
            identity_type = egress_policies.value.egress_from.identity_type
            dynamic "identities" {
              for_each = egress_policies.value.egress_from.identities
              content { identity = identities.value }
            }
          }
          egress_to {
            resources = egress_policies.value.egress_to.resources
            dynamic "operations" {
              for_each = egress_policies.value.egress_to.operations
              content {
                service_name = operations.value.service_name
                dynamic "method_selectors" {
                  for_each = operations.value.method_selectors
                  content { method = method_selectors.value.method }
                }
              }
            }
          }
        }
      }
    }
  }

  depends_on = [google_access_context_manager_access_level.levels]
}

resource "google_bigquery_dataset" "vpc_sc_logs" {
  dataset_id                 = local.bq_dataset_id
  project                    = var.config.project_id
  friendly_name              = var.config.bigquery.friendly_name
  description                = var.config.bigquery.description
  location                   = var.config.bigquery.location
  delete_contents_on_destroy = var.config.bigquery.delete_contents_on_destroy

  default_table_expiration_ms = var.config.bigquery.default_table_expiration_ms

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
resource "google_logging_project_sink" "vpc_sc_sink" {
  name        = var.config.log_sink.name
  project     = var.config.project_id
  description = var.config.log_sink.description
  destination = local.log_sink_destination
  filter = var.config.log_sink.filter
  unique_writer_identity = true

  bigquery_options {
    use_partitioned_tables = true
  }
  depends_on = [google_bigquery_dataset.vpc_sc_logs]
}

resource "google_bigquery_dataset_iam_member" "log_sink_writer" {
  project    = var.config.project_id
  dataset_id = google_bigquery_dataset.vpc_sc_logs.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.vpc_sc_sink.writer_identity

  depends_on = [
    google_bigquery_dataset.vpc_sc_logs,
    google_logging_project_sink.vpc_sc_sink,
  ]
}
