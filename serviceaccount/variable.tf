variable "config" {
  description = "All configuration values for GCP Service Accounts with Keys, IAM bindings, and Secret Manager"
  type = object({

    project_id = string
    region     = string

    secret_manager_project_id = string

    service_accounts = list(object({
      account_id   = string       # e.g. "sa-ci-deployer"
      display_name = string       # Human-readable name
      description  = string       # Purpose of the SA
      deploy       = bool         # Set false to skip creation
      roles        = list(string) # IAM roles on the host project
      secret_id    = string       # Existing secret ID in secret_manager_project_id
    }))
  })
}
