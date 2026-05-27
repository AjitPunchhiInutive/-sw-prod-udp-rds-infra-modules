variable "org_policies" {
  description = "Org policies configuration — set either folder_id OR project_id, not both"

  type = object({
    deploy     = bool
    folder_id  = optional(string, null)   # Set this for Folder-level policy
    project_id = optional(string, null)   # Set this for Project-level policy
    org_id     = optional(string, null)   # Set this for Org-level policy (custom constraints only)
    policy_boolean = optional(map(bool), {})
    policy_list = optional(map(object({
      inherit_from_parent = optional(bool, false)
      suggested_value     = optional(string, "")
      status              = bool
      values              = list(string)
    })), {})
    policy_custom = optional(list(object({
      name           = string           # Full constraint name: organizations/{org_id}/customConstraints/custom.xxx
      resource_types = string           # Single resource type, e.g. analyticshub.googleapis.com/DataExchange
      method_types   = list(string)     # e.g. ["CREATE", "UPDATE"]
      condition      = string           # CEL expression, e.g. resource.discoveryType == 'DISCOVERY_TYPE_PUBLIC'
      action_type    = string           # ALLOW or DENY
      display_name   = optional(string, "")
      description    = optional(string, "")
    })), [])
  })


  validation {
    condition = length([
      for v in [var.org_policies.folder_id, var.org_policies.project_id, var.org_policies.org_id] : v if v != null
    ]) <= 1
    error_message = "Only one of 'folder_id', 'project_id', or 'org_id' may be set at a time."
  }

  validation {
    condition = (
      !var.org_policies.deploy ||
      (var.org_policies.folder_id != null || var.org_policies.project_id != null || var.org_policies.org_id != null)
    )
    error_message = "When deploy is true, you must provide one of 'folder_id', 'project_id', or 'org_id'."
  }
}
