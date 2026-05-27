locals {

  is_folder  = var.org_policies.folder_id != null
  is_project = var.org_policies.project_id != null
  is_org     = var.org_policies.org_id != null

  parent = local.is_folder ? "folders/${var.org_policies.folder_id}" : (
    local.is_project ? "projects/${var.org_policies.project_id}" : (
      local.is_org ? "organizations/${var.org_policies.org_id}" : null
    )
  )

  # Split keys by whether constraint name contains ".managed."
  managed_boolean_keys  = toset([for k in keys(var.org_policies.policy_boolean) : k if strcontains(k, ".managed.")])
  standard_boolean_keys = toset([for k in keys(var.org_policies.policy_boolean) : k if !strcontains(k, ".managed.")])
  managed_list_keys     = toset([for k in keys(var.org_policies.policy_list) : k if strcontains(k, ".managed.")])
  standard_list_keys    = toset([for k in keys(var.org_policies.policy_list) : k if !strcontains(k, ".managed.")])

  # V1 — Folder standard boolean
  folder_boolean_policies_standard = local.is_folder && var.org_policies.deploy ? {
    for k in local.standard_boolean_keys : k => {
      folder_id  = var.org_policies.folder_id
      constraint = k
      enforce    = var.org_policies.policy_boolean[k]
    }
  } : {}

  # V1 — Folder standard list
  folder_list_policies_standard = local.is_folder && var.org_policies.deploy ? {
    for k in local.standard_list_keys : k => {
      folder_id           = var.org_policies.folder_id
      constraint          = k
      inherit_from_parent = var.org_policies.policy_list[k].inherit_from_parent
      suggested_value     = var.org_policies.policy_list[k].suggested_value
      status              = var.org_policies.policy_list[k].status
      values              = var.org_policies.policy_list[k].values
    }
  } : {}

  # V1 — Project standard boolean
  project_boolean_policies_standard = local.is_project && var.org_policies.deploy ? {
    for k in local.standard_boolean_keys : k => {
      project_id = var.org_policies.project_id
      constraint = k
      enforce    = var.org_policies.policy_boolean[k]
    }
  } : {}

  # V1 — Project standard list
  project_list_policies_standard = local.is_project && var.org_policies.deploy ? {
    for k in local.standard_list_keys : k => {
      project_id          = var.org_policies.project_id
      constraint          = k
      inherit_from_parent = var.org_policies.policy_list[k].inherit_from_parent
      suggested_value     = var.org_policies.policy_list[k].suggested_value
      status              = var.org_policies.policy_list[k].status
      values              = var.org_policies.policy_list[k].values
    }
  } : {}

  # V2 — Managed boolean (.managed. constraints)
  managed_boolean_policies = var.org_policies.deploy && local.parent != null ? {
    for k in local.managed_boolean_keys : k => {
      parent          = local.parent
      constraint_name = replace(k, "constraints/", "")
      enforce         = var.org_policies.policy_boolean[k]
    }
  } : {}

  # V2 — Managed list (.managed. constraints)
  managed_list_policies = var.org_policies.deploy && local.parent != null ? {
    for k in local.managed_list_keys : k => {
      parent              = local.parent
      constraint_name     = replace(k, "constraints/", "")
      inherit_from_parent = var.org_policies.policy_list[k].inherit_from_parent
      suggested_value     = var.org_policies.policy_list[k].suggested_value
      status              = var.org_policies.policy_list[k].status
      values              = var.org_policies.policy_list[k].values
    }
  } : {}

  # Custom constraints — keyed by the short constraint name extracted from the full resource name
  # e.g. "organizations/728935495814/customConstraints/custom.enforceDataExchangeDiscovery"
  #   => key: "custom.enforceDataExchangeDiscovery"
  custom_policies = var.org_policies.deploy && local.parent != null ? {
    for c in var.org_policies.policy_custom :
    regex("customConstraints/(.+)$", c.name)[0] => {
      name           = c.name
      resource_types = c.resource_types
      method_types   = c.method_types
      condition      = c.condition
      action_type    = c.action_type
      display_name   = c.display_name
      description    = c.description
      parent         = local.parent
      # Constraint name used in the enforcement policy, e.g. "customConstraints/custom.xxx"
      constraint_name = regex("(customConstraints/.+)$", c.name)[0]
    }
  } : {}
}
