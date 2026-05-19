
variable "config" {
  description = "All configuration for VPC Service Controls — access policy, perimeter, projects, restricted services, and GCS log bucket."

  type = object({

  
    org_id = string
    folder_ids = optional(list(string), [])
    projects = list(object({
      project_id     = string
      project_number = string
      region         = optional(string, "us-central1")
    }))
    primary_project_id     = string
    primary_project_number = string
    region                 = optional(string, "us-central1")
    create_access_policy = optional(bool, false)
    access_policy_title  = optional(string, "VPC SC Access Policy")
    existing_policy_id   = optional(string, "")
    perimeter_name        = string
    perimeter_title       = optional(string, "VPC SC Perimeter")
    perimeter_description = optional(string, "Managed by Terraform")
    dry_run = optional(bool, true)
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
      "file.googleapis.com",
      "netapp.googleapis.com",
      # Data & Analytics
      "bigquery.googleapis.com",
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
      "cloudsearch.googleapis.com",
    ])

    # ------- Access Levels ----------------------------------------
    access_levels = optional(list(object({
      name        = string
      description = optional(string, "")
      members     = list(string)
    })), [])

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
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,49}$", var.config.perimeter_name))
    error_message = "perimeter_name must start with a letter, max 50 chars, letters/digits/underscores only — no hyphens."
  }

  validation {
    condition     = var.config.create_access_policy == false ? length(var.config.existing_policy_id) > 0 : true
    error_message = "existing_policy_id must be set when create_access_policy = false."
  }

  validation {
    condition = alltrue([
      for al in var.config.access_levels :
      can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,49}$", al.name))
    ])
    error_message = "access_levels[*].name must start with a letter, max 50 chars, letters/digits/underscores only — no hyphens."
  }
}
