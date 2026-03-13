resource "google_folder_organization_policy" "boolean_policies" {
  for_each = { for p in local.folder_boolean_policies : p.key => p }

  folder     = each.value.folder_id
  constraint = each.value.constraint

  boolean_policy {
    enforced = each.value.enforce
  }
}

resource "google_folder_organization_policy" "list_policies" {
  for_each = { for p in local.folder_list_policies : p.key => p }

  folder     = each.value.folder_id
  constraint = each.value.constraint

  list_policy {
    inherit_from_parent = each.value.inherit_from_parent
    suggested_value     = each.value.suggested_value

    dynamic "allow" {
      for_each = each.value.status ? [1] : []
      content {
        values = each.value.values
      }
    }

    dynamic "deny" {
      for_each = !each.value.status ? [1] : []
      content {
        values = each.value.values
      }
    }
  }
}

resource "google_project_organization_policy" "boolean_policies" {
  for_each = { for p in local.project_boolean_policies : p.key => p }

  project    = each.value.project_id
  constraint = each.value.constraint

  boolean_policy {
    enforced = each.value.enforce
  }
}

resource "google_org_policy_policy" "folder_list_dryrun_policies" {
  for_each = { for p in local.folder_list_dryrun_policies : p.key => p }

  name   = "folders/${each.value.folder_id}/policies/${replace(each.value.constraint, "constraints/", "")}"
  parent = "folders/${each.value.folder_id}"

  dry_run_spec {
    inherit_from_parent = each.value.inherit_from_parent

    dynamic "rules" {
      for_each = length(each.value.values) > 0 ? [1] : []
      content {
        values {
          allowed_values = each.value.status ? each.value.values : null
          denied_values  = !each.value.status ? each.value.values : null
        }
      }
    }

    dynamic "rules" {
      for_each = length(each.value.values) == 0 && !each.value.status ? [1] : []
      content {
        deny_all = "TRUE"
      }
    }
  }
}

resource "google_org_policy_policy" "project_list_dryrun_policies" {
  for_each = { for p in local.project_list_dryrun_policies : p.key => p }

  name   = "projects/${each.value.project_id}/policies/${replace(each.value.constraint, "constraints/", "")}"
  parent = "projects/${each.value.project_id}"

  dry_run_spec {
    inherit_from_parent = each.value.inherit_from_parent

    dynamic "rules" {
      for_each = length(each.value.values) > 0 ? [1] : []
      content {
        values {
          allowed_values = each.value.status ? each.value.values : null
          denied_values  = !each.value.status ? each.value.values : null
        }
      }
    }

    dynamic "rules" {
      for_each = length(each.value.values) == 0 && !each.value.status ? [1] : []
      content {
        deny_all = "TRUE"
      }
    }
  }
}

resource "google_project_organization_policy" "list_policies" {
  for_each = { for p in local.project_list_policies : p.key => p }

  project    = each.value.project_id
  constraint = each.value.constraint

  list_policy {
    inherit_from_parent = each.value.inherit_from_parent
    suggested_value     = each.value.suggested_value

    dynamic "allow" {
      for_each = each.value.status ? [1] : []
      content {
        values = each.value.values
      }
    }

    dynamic "deny" {
      for_each = !each.value.status ? [1] : []
      content {
        values = each.value.values
      }
    }
  }
}
