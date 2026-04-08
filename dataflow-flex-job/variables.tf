variable "project_id" {
  description = "Project ID where the Dataflow job will run."
  type        = string
}

variable "region" {
  description = "Region for the Dataflow job."
  type        = string
}

variable "name" {
  description = "Base name for the Dataflow Flex Template job. A random suffix is appended to prevent name collision on restart."
  type        = string
}

variable "container_spec_gcs_path" {
  description = "GCS path to the Dataflow Flex Template container spec JSON file."
  type        = string
}

variable "staging_location" {
  description = "GCS path for Dataflow staging files."
  type        = string
}

variable "temp_location" {
  description = "GCS path for Dataflow temporary files."
  type        = string
}

variable "service_account_email" {
  description = "Service account email for Dataflow worker VMs."
  type        = string
}

variable "labels" {
  description = "Labels to apply to the Dataflow job."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "machine_type" {
  description = "Machine type for Dataflow worker VMs."
  type        = string
  default     = "n1-standard-2"
}

variable "max_workers" {
  description = "Maximum number of Dataflow worker VMs."
  type        = number
  default     = 100
}

variable "num_workers" {
  description = "Initial number of Dataflow worker VMs."
  type        = number
  default     = 1
}

variable "subnetwork" {
  description = "Subnetwork self-link for Dataflow workers. Set to null to use the default network."
  type        = string
  default     = null
}

variable "use_public_ips" {
  description = "Assign public IPs to Dataflow workers."
  type        = bool
  default     = false
}

variable "enable_streaming_engine" {
  description = "Enable Dataflow Streaming Engine."
  type        = bool
  default     = true
}

variable "skip_wait_on_job_termination" {
  description = "Prevent Terraform from waiting for the job to terminate. Required for streaming jobs."
  type        = bool
  default     = true
}

variable "additional_experiments" {
  description = "Additional experiment flags to pass to the Dataflow job."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "parameters" {
  description = "Pipeline-specific parameters passed to the Flex Template."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "on_delete" {
  description = "Action when the resource is deleted. One of drain or cancel."
  type        = string
  default     = "drain"
  validation {
    condition     = contains(["drain", "cancel"], var.on_delete)
    error_message = "on_delete must be one of: drain, cancel."
  }
}
