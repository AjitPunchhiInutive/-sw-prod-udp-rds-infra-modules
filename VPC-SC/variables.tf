# =============================================================
# variables.tf — Single Consolidated Input Variable
# =============================================================

variable "config" {
  description = "All configuration for VPC Service Controls — access policy, perimeter, projects, and restricted services."

  type = object({

    # ------- Organization -----------------------------------------
    org_id = string

    # ------- Multiple Projects ------------------------------------
    # All projects added to the VPC SC perimeter
    projects = list(object({
      project_id     = string
      project_number = string
      region         = optional(string, "us-central1")
    }))

    # Primary project — hosts BigQuery, Storage, Log Sink resources
    primary_project_id     = string
    primary_project_number = string
    region                 = optional(string, "us-central1")

    # ------- Access Policy ----------------------------------------
    # create_access_policy = true  → creates new org-level policy
    # create_access_policy = false → uses existing_policy_id
    create_access_policy = optional(bool, false)
    access_policy_title  = optional(string, "VPC SC Access Policy")
    existing_policy_id   = optional(string, "")

    # ------- Perimeter --------------------------------------------
    perimeter_name        = string
    perimeter_title       = optional(string, "VPC SC Perimeter")
    perimeter_description = optional(string, "Managed by Terraform")

    # ------- Dry Run ----------------------------------------------
    # true  → DRY_RUN  — violations are logged, nothing is blocked
    # false → ENFORCED — violations are actively denied
    dry_run = optional(bool, true)

    # ------- Restricted Services ----------------------------------
    # Defaults to all GA-supported VPC SC services.
    # Override with a custom list if needed.
    restricted_services = optional(list(string), [
      # Core Compute & Infrastructure
      "compute.googleapis.com",
      "container.googleapis.com",
      "containerregistry.googleapis.com",
      "artifactregistry.googleapis.com",
      "cloudkms.googleapis.com",
      "iam.googleapis.com",
      "iamcredentials.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "config.googleapis.com",
      "workloadmanager.googleapis.com",
      # Storage
      "storage.googleapis.com",
      "storage-api.googleapis.com",
      "storage-component.googleapis.com",
      "file.googleapis.com",
      "netapp.googleapis.com",
      # Data & Analytics
      "bigquery.googleapis.com",
      "bigquerystorage.googleapis.com",
      "bigqueryconnection.googleapis.com",
      "biglake.googleapis.com",
      "dataflow.googleapis.com",
      "dataproc.googleapis.com",
      "pubsub.googleapis.com",
      "spanner.googleapis.com",
      "bigtable.googleapis.com",
      "firestore.googleapis.com",
      "sqladmin.googleapis.com",
      "alloydb.googleapis.com",
      "redis.googleapis.com",
      "datacatalog.googleapis.com",
      "dataplex.googleapis.com",
      # Secrets & Security
      "secretmanager.googleapis.com",
      "accessapproval.googleapis.com",
      "cloudtrace.googleapis.com",
      "monitoring.googleapis.com",
      "logging.googleapis.com",
      # Networking
      "dns.googleapis.com",
      "networkconnectivity.googleapis.com",
      "networkmanagement.googleapis.com",
      "servicenetworking.googleapis.com",
      "vpcaccess.googleapis.com",
      # Serverless & ML
      "cloudfunctions.googleapis.com",
      "run.googleapis.com",
      "aiplatform.googleapis.com",
      "notebooks.googleapis.com",
      "ml.googleapis.com",
      # DevOps & CI/CD
      "cloudbuild.googleapis.com",
      "sourcerepo.googleapis.com",
      "cloudsearch.googleapis.com",
    ])

    # ------- Access Levels ----------------------------------------
    access_levels = optional(list(object({
      name        = string
      description = optional(string, "")
      members     = list(string)
    })), [])

    # ------- BigQuery Audit Dataset -------------------------------
    bigquery = object({
      location                    = optional(string, "US")
      audit_dataset_id            = string
      audit_friendly_name         = optional(string, "VPC SC Audit Logs")
      audit_description           = optional(string, "Stores VPC SC audit and violation logs")
      default_table_expiration_ms = optional(number, 7776000000)  # 90 days
      partition_expiration_ms     = optional(number, 7776000000)  # 90 days
      delete_contents_on_destroy  = optional(bool, false)
    })

    # ------- Log Sink ---------------------------------------------
    log_sink = object({
      name        = string
      description = optional(string, "VPC SC audit log sink to BigQuery")
      filter      = optional(string, "protoPayload.status.code!=0 OR log_id(\"cloudaudit.googleapis.com/policy\")")
    })

    # ------- Labels -----------------------------------------------
    labels = optional(map(string), {})
  })

  # ── Validations ───────────────────────────────────────────────

  validation {
    condition     = length(var.config.org_id) > 0
    error_message = "config.org_id must not be empty."
  }

  validation {
    condition     = length(var.config.projects) > 0
    error_message = "config.projects must contain at least one project."
  }

  validation {
    condition     = length(var.config.primary_project_id) > 0
    error_message = "config.primary_project_id must not be empty."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]{0,28}[a-z0-9]$", var.config.perimeter_name))
    error_message = "perimeter_name must be lowercase letters, digits, hyphens, or underscores (6-30 chars)."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9_]*$", var.config.bigquery.audit_dataset_id))
    error_message = "bigquery.audit_dataset_id must start with a letter and contain only lowercase letters, numbers, or underscores."
  }

  validation {
    condition     = var.config.create_access_policy == false ? length(var.config.existing_policy_id) > 0 : true
    error_message = "existing_policy_id must be set when create_access_policy = false."
  }
}
