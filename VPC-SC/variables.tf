# =============================================================
# variables.tf — Single Consolidated Input Variable
# =============================================================

variable "config" {
  description = "All configuration for Access Policy, VPC SC Perimeter, Storage, BigQuery, and Log Sink."

  type = object({

    # ------- Organization -----------------------------------------
    org_id = string

    # ------- Project ----------------------------------------------
    project_id     = string
    project_number = string
    region         = optional(string, "us-central1")

    # ------- Access Policy ----------------------------------------
    create_access_policy  = optional(bool, true)
    access_policy_title   = optional(string, "VPC SC Access Policy")
    existing_policy_id    = optional(string, "")   # used when create_access_policy = false

    # ------- Perimeter --------------------------------------------
    perimeter_name        = string
    perimeter_title       = optional(string, "VPC SC Perimeter")
    perimeter_description = optional(string, "Managed by Terraform")

    # ------- Dry Run ----------------------------------------------
    # true  = DRY_RUN  → violations logged, nothing blocked
    # false = ENFORCED → violations actively denied
    dry_run = optional(bool, true)

    # ------- Restricted Services ----------------------------------
    restricted_services = optional(list(string), [
      "bigquery.googleapis.com",
      "storage.googleapis.com",
      "biglake.googleapis.com",
      "bigqueryconnection.googleapis.com",
      "secretmanager.googleapis.com",
    ])

    # ------- Access Levels ----------------------------------------
    access_levels = optional(list(object({
      name        = string
      description = optional(string, "")
      members     = list(string)
    })), [])

    # ------- Cloud Storage ----------------------------------------
    storage = object({
      bucket_name               = string
      location                  = optional(string, "US")
      storage_class             = optional(string, "STANDARD")
      versioning_enabled        = optional(bool, true)
      force_destroy             = optional(bool, false)
      lifecycle_delete_age_days = optional(number, 90)
    })

    # ------- BigQuery ---------------------------------------------
    bigquery = object({
      location = optional(string, "US")

      # Workload data dataset
      data_dataset_id    = string
      data_friendly_name = optional(string, "Data Dataset")
      data_description   = optional(string, "Primary workload data dataset")

      # Audit log dataset (receives log sink)
      audit_dataset_id            = string
      audit_friendly_name         = optional(string, "Audit Logs Dataset")
      audit_description           = optional(string, "Stores VPC SC audit logs")
      default_table_expiration_ms = optional(number, 7776000000)  # 90 days
      partition_expiration_ms     = optional(number, 7776000000)  # 90 days
      delete_contents_on_destroy  = optional(bool, false)
    })

    # ------- Log Sink ---------------------------------------------
    log_sink = object({
      name        = string
      description = optional(string, "VPC SC audit log sink")
      filter      = optional(string, "protoPayload.status.code!=0 OR log_id(\"cloudaudit.googleapis.com/policy\")")
    })

    # ------- Labels -----------------------------------------------
    labels = optional(map(string), {})
  })

  # ── Validations ──────────────────────────────────────────────

  validation {
    condition     = length(var.config.org_id) > 0
    error_message = "config.org_id must not be empty."
  }

  validation {
    condition     = length(var.config.project_id) > 0
    error_message = "config.project_id must not be empty."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]{0,28}[a-z0-9]$", var.config.perimeter_name))
    error_message = "perimeter_name must be lowercase letters, digits, hyphens, or underscores (6-30 chars)."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9_]{0,1022}$", var.config.bigquery.data_dataset_id))
    error_message = "bigquery.data_dataset_id must start with a letter and contain only lowercase letters, numbers, or underscores."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9_]{0,1022}$", var.config.bigquery.audit_dataset_id))
    error_message = "bigquery.audit_dataset_id must start with a letter and contain only lowercase letters, numbers, or underscores."
  }

  validation {
    condition     = var.config.create_access_policy == false ? length(var.config.existing_policy_id) > 0 : true
    error_message = "existing_policy_id must be set when create_access_policy = false."
  }
}
