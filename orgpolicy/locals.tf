locals {

  # ── Determine target type ────────────────────────────────────────────────────
  is_folder  = var.org_policies.folder_id != null
  is_project = var.org_policies.project_id != null

  # ── Parent string for V2 resource ───────────────────────────────────────────
  parent = local.is_folder ? "folders/${var.org_policies.folder_id}" : (
    local.is_project ? "projects/${var.org_policies.project_id}" : null
  )

  # ─────────────────────────────────────────────────────────────────────────────
  # SPLIT LOGIC — key rule:
  #   Any constraint containing ".managed." (e.g. iam.managed.xxx,
  #   dataflow.managed.xxx, compute.managed.xxx, run.managed.xxx)
  #   MUST use V2 google_org_policy_policy resource.
  #   All others use V1 google_folder/project_organization_policy.
  # ─────────────────────────────────────────────────────────────────────────────

  # Helper sets — precompute which constraints are managed vs standard
  all_boolean_keys = keys(var.org_policies.policy_boolean)
  all_list_keys    = keys(var.org_policies.policy_list)

  managed_boolean_keys  = toset([for k in local.all_boolean_keys : k if strcontains(k, ".managed.")])
  standard_boolean_keys = toset([for k in local.all_boolean_keys : k if !strcontains(k, ".managed.")])
  managed_list_keys     = toset([for k in local.all_list_keys : k if strcontains(k, ".managed.")])
  standard_list_keys    = toset([for k in local.all_list_keys : k if !strcontains(k, ".managed.")])

  # ── V1: Folder Standard Boolean ──────────────────────────────────────────────
  folder_boolean_policies_standard = local.is_folder && var.org_policies.deploy ? {
    for k in local.standard_boolean_keys : k => {
      folder_id  = var.org_policies.folder_id
      constraint = k
      enforce    = var.org_policies.policy_boolean[k]
    }
  } : {}

  # ── V1: Folder Standard List ─────────────────────────────────────────────────
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

  # ── V1: Project Standard Boolean ─────────────────────────────────────────────
  project_boolean_policies_standard = local.is_project && var.org_policies.deploy ? {
    for k in local.standard_boolean_keys : k => {
      project_id = var.org_policies.project_id
      constraint = k
      enforce    = var.org_policies.policy_boolean[k]
    }
  } : {}

  # ── V1: Project Standard List ────────────────────────────────────────────────
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

  # ── V2: Managed Boolean (.managed. — folder or project) ──────────────────────
  managed_boolean_policies = var.org_policies.deploy && local.parent != null ? {
    for k in local.managed_boolean_keys : k => {
      parent          = local.parent
      constraint_name = replace(k, "constraints/", "")
      enforce         = var.org_policies.policy_boolean[k]
    }
  } : {}

  # ── V2: Managed List (.managed. — folder or project) ─────────────────────────
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
