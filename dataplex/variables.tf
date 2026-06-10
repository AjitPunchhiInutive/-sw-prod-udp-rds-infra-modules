variable "iam" {
  description = "Dataplex lake IAM bindings in {ROLE => [MEMBERS]} format."
  type        = map(list(string))
  default     = {}
  nullable    = false
}

variable "location_type" {
  description = "The location type of the Dataplax Lake."
  type        = string
  default     = "SINGLE_REGION"
}

variable "name" {
  description = "Name of Dataplex Lake."
  type        = string
}

variable "display_name" {
  description = "Optional display name of the Dataplex Lake."
  type        = string
  default     = null
}

variable "description" {
  description = "Optional description of the Dataplex Lake."
  type        = string
  default     = null
}

variable "prefix" {
  description = "Optional prefix used to generate Dataplex Lake."
  type        = string
  default     = null
}

variable "project_id" {
  description = "The ID of the project where this Dataplex Lake will be created."
  type        = string
}

variable "region" {
  description = "Region of the Dataplax Lake."
  type        = string
}

variable "zones" {
  description = "Dataplex lake zones, such as `RAW` and `CURATED`."
  type = map(object({
    type          = string
    display_name  = optional(string)
    description   = optional(string)
    discovery     = optional(bool, true)
    cron_schedule = optional(string)               # ← ADD zone-level cron
    iam           = optional(map(list(string)), null)
    assets = map(object({
      resource_name          = string
      display_name           = optional(string)
      description            = optional(string)
      resource_project       = optional(string)
      cron_schedule          = optional(string)    # ← remove default so null means inherit
      discovery_spec_enabled = optional(bool, true)
      resource_spec_type     = optional(string, "STORAGE_BUCKET")
    }))
  }))
  validation {
    condition = alltrue(flatten([
      for k, v in var.zones : [
        for kk, vv in v.assets : contains(["BIGQUERY_DATASET", "STORAGE_BUCKET"], vv.resource_spec_type)
      ]
    ]))
    error_message = "Asset spect type must be one of 'BIGQUERY_DATASET' or 'STORAGE_BUCKET'."
  }
}