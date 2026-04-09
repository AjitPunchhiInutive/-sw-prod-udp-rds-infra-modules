variable "jobs" {
  description = "List of Dataflow Flex Template jobs. Set deploy = false to skip a job without removing its YAML."
  nullable    = false

  type = list(object({
    deploy                       = optional(bool, true)
    project_id                   = string
    region                       = string
    job_name                     = string
    on_delete                    = optional(string, "drain")
    container_spec_gcs_path      = string
    service_account_email        = string
    machine_type                 = optional(string, "n1-standard-2")
    num_workers                  = optional(number, 1)
    max_workers                  = optional(number, 100)
    enable_streaming_engine      = optional(bool, true)
    ip_configuration             = optional(string, "WORKER_IP_PRIVATE")
    skip_wait_on_job_termination = optional(bool, true)
    staging_location             = string
    temp_location                = string
    subnetwork                   = optional(string, null)
    additional_experiments       = optional(list(string), [])
    parameters                   = optional(map(string), {})
    labels                       = optional(map(string), {})
  }))

  validation {
    condition     = alltrue([for v in var.jobs : contains(["drain", "cancel"], v.on_delete)])
    error_message = "on_delete must be one of: drain, cancel."
  }

  validation {
    condition     = alltrue([for v in var.jobs : contains(["WORKER_IP_PRIVATE", "WORKER_IP_PUBLIC"], v.ip_configuration)])
    error_message = "ip_configuration must be one of: WORKER_IP_PRIVATE, WORKER_IP_PUBLIC."
  }
}
