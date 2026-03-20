# =============================================================
# variables.tf — Single Consolidated Input Variable
# =============================================================

variable "config" {
  description = "All configuration for VPC Service Controls, BigQuery audit log dataset, and Log Sink."

  type = object({

    # ------- Organization & Policy ----------------------------
    org_id    = string
    policy_id = string        # Existing Access Context Manager policy ID

    # ------- Project ------------------------------------------
    project_id     = string
    project_number = string
    region         = optional(string, "US")

    # ------- Perimeter ----------------------------------------
    perimeter_name        = string
    perimeter_title       = optional(string, "VPC SC Perimeter")
    perimeter_description = optional(string, "Managed by Terraform")

    # ------- Dry Run ------------------------------------------
    # true  = DRY_RUN  → violations are audit-logged, nothing blocked
    # false = ENFORCED → violations are actively denied
    dry_run = optional(bool, true)

    # ------- Restricted Services ------------------------------
    restricted_services = optional(list(string), [
      "bigquery.googleapis.com",
      "storage.googleapis.com",
      "biglake.googleapis.com",
      "bigqueryconnection.googleapis.com",
      "secretmanager.googleapis.com",
    ])

    # ------- Access Levels ------------------------------------
    access_levels = optional(list(object({
      name        = string
      description = optional(string, "")
      members     = list(string)
    })), [])

    # ------- BigQuery Audit Log Dataset -----------------------
    bigquery = object({
      dataset_id                  = string
      friendly_name               = optional(string, "VPC SC Audit Logs")
      description                 = optional(string, "Stores VPC SC violation and audit logs")
      location                    = optional(string, "US")
      default_table_expiration_ms = optional(number, 7776000000)  # 90 days
      partition_expiration_ms     = optional(number, 7776000000)  # 90 days
      delete_contents_on_destroy  = optional(bool, false)
    })

    # ------- Log Sink -----------------------------------------
    log_sink = object({
      name        = string
      description = optional(string, "VPC SC audit log sink to BigQuery")
      filter      = optional(string, "protoPayload.status.code!=0 OR log_id(\"cloudaudit.googleapis.com/policy\")")
    })

    # ------- Labels -------------------------------------------
    labels = optional(map(string), {})
  })

  # --- Validations -------------------------------------------

  validation {
    condition     = length(var.config.org_id) > 0
    error_message = "config.org_id must not be empty."
  }

  validation {
    condition     = length(var.config.project_id) > 0
    error_message = "config.project_id must not be empty."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9_]{0,1022}$", var.config.bigquery.dataset_id))
    error_message = "config.bigquery.dataset_id must start with a letter and contain only lowercase letters, numbers, or underscores."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]{0,28}[a-z0-9]$", var.config.perimeter_name))
    error_message = "config.perimeter_name must be lowercase letters, digits, hyphens, or underscores."
  }
}
