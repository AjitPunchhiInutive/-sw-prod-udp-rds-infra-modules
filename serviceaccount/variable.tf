variable "config" {
  description = "All configuration values for GCP Service Accounts, IAM bindings, and Secret Manager"
  type = object({

    project_id = string
    region     = string

    secret_manager_project_id = string

    service_accounts_with_key = list(object({
      account_id   = string
      display_name = string
      description  = string
      roles        = list(string)
      secret_id    = string
    }))

    service_accounts_without_key = list(object({
      account_id   = string
      display_name = string
      description  = string
      roles        = list(string)
    }))
  })
}
