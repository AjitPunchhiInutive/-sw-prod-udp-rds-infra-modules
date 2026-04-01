variable "project_id" {
  description = "GCP project ID where the log sinks will be created"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
}

# ──────────────────────────────────────────────
# GCS Sink
# ──────────────────────────────────────────────
variable "gcs_sink_name" {
  description = "Name for the GCS log sink"
  type        = string
}

variable "gcs_bucket_name" {
  description = "Name of the existing GCS bucket to send logs to"
  type        = string
}

variable "gcs_filter_severity" {
  description = "Minimum log severity for GCS sink. One of: DEFAULT, DEBUG, INFO, NOTICE, WARNING, ERROR, CRITICAL, ALERT, EMERGENCY. Empty = all severities."
  type        = string
  default     = ""

  validation {
    condition = contains(
      ["", "DEFAULT", "DEBUG", "INFO", "NOTICE", "WARNING", "ERROR", "CRITICAL", "ALERT", "EMERGENCY"],
      var.gcs_filter_severity
    )
    error_message = "Must be a valid GCP log severity or empty string."
  }
}

variable "gcs_filter_resource_types" {
  description = "List of resource types to include (e.g. [\"gce_instance\", \"gcs_bucket\"]). Empty = all."
  type        = list(string)
  default     = []
}

variable "gcs_filter_log_names" {
  description = "List of log names to include (e.g. [\"cloudaudit.googleapis.com/activity\"]). Empty = all."
  type        = list(string)
  default     = []
}

variable "gcs_filter_extra" {
  description = "Additional raw filter expression ANDed with the GCS sink filter (for advanced use cases)"
  type        = string
  default     = ""
}

# ──────────────────────────────────────────────
# BigQuery Sink
# ──────────────────────────────────────────────
variable "bq_sink_name" {
  description = "Name for the BigQuery log sink"
  type        = string
}

variable "bq_dataset_id" {
  description = "ID of the existing BigQuery dataset to send logs to"
  type        = string
}

variable "bq_use_partitioned_tables" {
  description = "Whether to use partitioned tables in BigQuery"
  type        = bool
  default     = true
}

variable "bq_filter_severity" {
  description = "Minimum log severity for BQ sink. One of: DEFAULT, DEBUG, INFO, NOTICE, WARNING, ERROR, CRITICAL, ALERT, EMERGENCY. Empty = all severities."
  type        = string
  default     = ""

  validation {
    condition = contains(
      ["", "DEFAULT", "DEBUG", "INFO", "NOTICE", "WARNING", "ERROR", "CRITICAL", "ALERT", "EMERGENCY"],
      var.bq_filter_severity
    )
    error_message = "Must be a valid GCP log severity or empty string."
  }
}

variable "bq_filter_resource_types" {
  description = "List of resource types to include (e.g. [\"cloudsql_database\", \"k8s_container\"]). Empty = all."
  type        = list(string)
  default     = []
}

variable "bq_filter_log_names" {
  description = "List of log names to include (e.g. [\"cloudaudit.googleapis.com/data_access\"]). Empty = all."
  type        = list(string)
  default     = []
}

variable "bq_filter_extra" {
  description = "Additional raw filter expression ANDed with the BQ sink filter (for advanced use cases)"
  type        = string
  default     = ""
}

# ──────────────────────────────────────────────
# Labels
# ──────────────────────────────────────────────
variable "labels" {
  description = "Additional labels to apply to resources"
  type        = map(string)
  default     = {}
}
