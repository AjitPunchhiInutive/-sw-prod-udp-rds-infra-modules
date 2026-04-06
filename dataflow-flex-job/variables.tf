variable "config" {
  description = "Configuration for the Dataflow Flex Template streaming job."

  type = object({
    project_id  = string
    region      = string
    environment = optional(string, "dev")
    labels      = optional(map(string), {})

    job_name                = string
    container_spec_gcs_path = string

    staging_location = string
    temp_location    = string

    machine_type = optional(string, "n1-standard-2")
    max_workers  = optional(number, 100)
    num_workers  = optional(number, 1)

    service_account_email = string

    subnetwork     = optional(string, "")
    use_public_ips = optional(bool, false)

    enable_streaming_engine      = optional(bool, true)
    skip_wait_on_job_termination = optional(bool, true)
    additional_experiments       = optional(list(string), [])

    parameters = optional(map(string), {})
    on_delete  = optional(string, "drain")
  })

  validation {
    condition     = length(var.config.project_id) > 0
    error_message = "config.project_id must not be empty."
  }

  validation {
    condition     = length(var.config.container_spec_gcs_path) > 0
    error_message = "config.container_spec_gcs_path must not be empty."
  }

  validation {
    condition     = length(var.config.service_account_email) > 0
    error_message = "config.service_account_email must not be empty."
  }

  validation {
    condition     = contains(["drain", "cancel"], var.config.on_delete)
    error_message = "config.on_delete must be one of: drain, cancel."
  }

  validation {
    condition     = contains(["dev", "staging", "prod"], var.config.environment)
    error_message = "config.environment must be one of: dev, staging, prod."
  }
}
