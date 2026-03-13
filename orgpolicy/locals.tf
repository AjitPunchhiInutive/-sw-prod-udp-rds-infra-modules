locals {

  is_folder  = var.org_policies.folder_id != null
  is_project = var.org_policies.project_id != null

  parent = local.is_folder ? "folders/${var.org_policies.folder_id}" : (
    local.is_project ? "projects/${var.org_policies.project_id}" : null
  )

  # Split keys by whether constraint name contains ".managed."
  managed_boolean_keys  = toset([for k in keys(var.org_policies.policy_boolean) : k if strcontains(k, ".managed.")])
  standard_boolean_keys = toset([for k in keys(var.org_policies.policy_boolean) : k if !strcontains(k, ".managed.")])
  managed_list_keys     = toset([for k in keys(var.org_policies.policy_list) : k if strcontains(k, ".managed.")])
  standard_list_keys    = toset([for k in keys(var.org_policies.policy_list) : k if !strcontains(k, ".managed.") && !var.org_policies.policy_list[k].dry_run])
  dryrun_list_keys      = toset([for k in keys(var.org_policies.policy_list) : k if !strcontains(k, ".managed.") && var.org_policies.policy_list[k].dry_run])

  # V1 — Folder standard boolean
  folder_boolean_policies_standard = local.is_folder && var.org_policies.deploy ? {
    for k in local.standard_boolean_keys : k => {
      folder_id  = var.org_policies.folder_id
      constraint = k
      enforce    = var.org_policies.policy_boolean[k]
    }
  } : {}

  # V1 — Folder standard list (excludes dry_run entries)
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

  # V2 — Folder dry_run list policies
  folder_list_dryrun_policies = var.org_policies.deploy && local.is_folder ? {
    for k in local.dryrun_list_keys : k => {
      folder_id           = var.org_policies.folder_id
      constraint_name     = replace(k, "constraints/", "")
      inherit_from_parent = var.org_policies.policy_list[k].inherit_from_parent
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

  # V1 — Project standard list (excludes dry_run entries)
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

  # V2 — Project dry_run list policies
  project_list_dryrun_policies = var.org_policies.deploy && local.is_project ? {
    for k in local.dryrun_list_keys : k => {
      project_id          = var.org_policies.project_id
      constraint_name     = replace(k, "constraints/", "")
      inherit_from_parent = var.org_policies.policy_list[k].inherit_from_parent
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
}
