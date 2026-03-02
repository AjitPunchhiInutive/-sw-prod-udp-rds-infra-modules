locals {

  is_folder  = var.org_policies.folder_id != null
  is_project = var.org_policies.project_id != null
  parent = local.is_folder ? "folders/${var.org_policies.folder_id}" : (
    local.is_project ? "projects/${var.org_policies.project_id}" : null
  )

  # ── V1: Standard boolean (folder) ───────────────────────────────────────────
  folder_boolean_policies_standard = local.is_folder && var.org_policies.deploy ? {
    for constraint, enforce in var.org_policies.policy_boolean :
    constraint => {
      folder_id  = var.org_policies.folder_id
      constraint = constraint
      enforce    = enforce
    }
    if !can(regex("\\.managed\\.", constraint))
  } : {}

  # ── V1: Standard list (folder) ──────────────────────────────────────────────
  folder_list_policies_standard = local.is_folder && var.org_policies.deploy ? {
    for constraint, config in var.org_policies.policy_list :
    constraint => {
      folder_id           = var.org_policies.folder_id
      constraint          = constraint
      inherit_from_parent = config.inherit_from_parent
      suggested_value     = config.suggested_value
      status              = config.status
      values              = config.values
    }
    if !can(regex("\\.managed\\.", constraint))
  } : {}

  # ── V1: Standard boolean (project) ──────────────────────────────────────────
  project_boolean_policies_standard = local.is_project && var.org_policies.deploy ? {
    for constraint, enforce in var.org_policies.policy_boolean :
    constraint => {
      project_id = var.org_policies.project_id
      constraint = constraint
      enforce    = enforce
    }
    if !can(regex("\\.managed\\.", constraint))
  } : {}

  # ── V1: Standard list (project) ─────────────────────────────────────────────
  project_list_policies_standard = local.is_project && var.org_policies.deploy ? {
    for constraint, config in var.org_policies.policy_list :
    constraint => {
      project_id          = var.org_policies.project_id
      constraint          = constraint
      inherit_from_parent = config.inherit_from_parent
      suggested_value     = config.suggested_value
      status              = config.status
      values              = config.values
    }
    if !can(regex("\\.managed\\.", constraint))
  } : {}

  # ── V2: Managed boolean (.managed. constraints) ──────────────────────────────
  managed_boolean_policies = var.org_policies.deploy && local.parent != null ? {
    for constraint, enforce in var.org_policies.policy_boolean :
    constraint => {
      parent          = local.parent
      constraint_name = replace(constraint, "constraints/", "")
      enforce         = enforce
    }
    if can(regex("\\.managed\\.", constraint))
  } : {}

  # ── V2: Managed list (.managed. constraints) ─────────────────────────────────
  managed_list_policies = var.org_policies.deploy && local.parent != null ? {
    for constraint, config in var.org_policies.policy_list :
    constraint => {
      parent              = local.parent
      constraint_name     = replace(constraint, "constraints/", "")
      inherit_from_parent = config.inherit_from_parent
      suggested_value     = config.suggested_value
      status              = config.status
      values              = config.values
    }
    if can(regex("\\.managed\\.", constraint))
  } : {}
}
