# =============================================================
# variables.tf — Single Consolidated Input Variable
# =============================================================

variable "config" {
  description = "All configuration for service account creation, key management, and Secret Manager integration."

  type = object({

    # ------- Project -------------------------------------------
    project_id  = string
    region      = optional(string, "us-central1")
    environment = optional(string, "prod")

    # ------- Secret Manager ------------------------------------
    secret_manager_project_id = optional(string, "")
    key_rotation_days         = optional(number, 90)

    # ------- Labels --------------------------------------------
    labels = optional(map(string), {})

    # ------- Service Accounts ----------------------------------
    service_accounts = optional(map(object({
      account_id   = string
      display_name = string
      description  = string
      iam_roles    = list(string)
      create_key   = bool
      secret_id    = optional(string)
    })), {})
  })

  validation {
    condition     = length(var.config.project_id) > 0
    error_message = "config.project_id must not be empty."
  }

  validation {
    condition     = contains(["prod", "staging", "dev"], var.config.environment)
    error_message = "config.environment must be one of: prod, staging, dev."
  }

  validation {
    condition = alltrue([
      for k, v in var.config.service_accounts :
      can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", v.account_id))
    ])
    error_message = "Each account_id must be 6-30 chars, lowercase letters, digits, and hyphens."
  }
}
