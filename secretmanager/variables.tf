variable "secrets" {
  description = "Map of secrets to create in GCP Secret Manager"
  type = map(object({
    deploy       = optional(bool, true)
    project_id   = string                        # (Required) GCP project ID
    secret_id    = string                        # (Required) Unique secret identifier
    labels       = optional(map(string), {})     # (Optional) Labels to attach to the secret
    annotations  = optional(map(string), {})     # (Optional) Annotations for the secret

    # Replication
    replication_type      = optional(string, "auto")   # "auto" or "user_managed"
    replication_locations = optional(list(string), []) # Required when replication_type = "user_managed"
    kms_key_name          = optional(string, null)     # CMEK key — applies to all replicas

    # Rotation
    # rotation_period    = optional(string, null) # e.g. "604800s" (7 days). Requires topics.
    # next_rotation_time = optional(string, null) # RFC3339 format e.g. "2025-01-01T00:00:00Z"
    #topics             = optional(list(string), []) # Pub/Sub topic names for rotation notifications

    # Expiration
    ttl = optional(string, null) # e.g. "86400s" (1 day). Cannot be used with expire_time.

    # Secret versions
    # versions = optional(map(object({
    #   secret_data = string           # (Required) The secret payload
    #   enabled     = optional(bool, true) # (Optional) Whether this version is enabled
    # })), {})

    # IAM bindings
    iam_bindings = optional(list(object({
      role   = string  # e.g. "roles/secretmanager.secretAccessor"
      member = string  # e.g. "serviceAccount:sa@project.iam.gserviceaccount.com"
    })), [])
  }))
  default = {}
}
