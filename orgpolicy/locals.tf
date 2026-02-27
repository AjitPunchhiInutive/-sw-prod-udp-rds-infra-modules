locals {

  is_folder  = var.org_policies.folder_id != null
  is_project = var.org_policies.project_id != null

  folder_boolean_policies = local.is_folder && var.org_policies.deploy ? [
    for constraint, enforce in var.org_policies.policy_boolean : {
      key        = constraint
      folder_id  = var.org_policies.folder_id
      constraint = constraint
      enforce    = enforce
    }
  ] : []

  folder_list_policies = local.is_folder && var.org_policies.deploy ? [
    for constraint, config in var.org_policies.policy_list : {
      key                 = constraint
      folder_id           = var.org_policies.folder_id
      constraint          = constraint
      inherit_from_parent = config.inherit_from_parent
      suggested_value     = config.suggested_value
      status              = config.status
      values              = config.values
    }
  ] : []

  project_boolean_policies = local.is_project && var.org_policies.deploy ? [
    for constraint, enforce in var.org_policies.policy_boolean : {
      key        = constraint
      project_id = var.org_policies.project_id
      constraint = constraint
      enforce    = enforce
    }
  ] : []

  project_list_policies = local.is_project && var.org_policies.deploy ? [
    for constraint, config in var.org_policies.policy_list : {
      key                 = constraint
      project_id          = var.org_policies.project_id
      constraint          = constraint
      inherit_from_parent = config.inherit_from_parent
      suggested_value     = config.suggested_value
      status              = config.status
      values              = config.values
    }
  ] : []
}
