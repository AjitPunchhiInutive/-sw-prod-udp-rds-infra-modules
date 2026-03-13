variable "org_policies" {
  description = "Org policies configuration — set either folder_id OR project_id, not both"

  type = object({
    deploy     = bool
    folder_id  = optional(string, null)   # Set this for Folder-level policy
    project_id = optional(string, null)   # Set this for Project-level policy
    policy_boolean = optional(map(bool), {})
    policy_list = optional(map(object({
      inherit_from_parent = optional(bool, false)
      suggested_value     = optional(string, "")
      status              = bool
      values              = list(string)
      dry_run             = optional(bool, false)
    })), {})
  })


  validation {
    condition = !(
      var.org_policies.folder_id != null && var.org_policies.project_id != null
    )
    error_message = "Only one of 'folder_id' or 'project_id' may be set at a time, not both."
  }

  validation {
    condition = (
      !var.org_policies.deploy ||
      (var.org_policies.folder_id != null || var.org_policies.project_id != null)
    )
    error_message = "When deploy is true, you must provide either 'folder_id' or 'project_id'."
  }
}
