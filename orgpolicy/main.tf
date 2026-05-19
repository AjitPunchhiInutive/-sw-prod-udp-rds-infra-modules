# V1 — Folder standard boolean (single-dot constraints only)
resource "google_folder_organization_policy" "boolean_policies" {
  for_each = local.folder_boolean_policies_standard

  folder     = each.value.folder_id
  constraint = each.value.constraint

  boolean_policy {
    enforced = each.value.enforce
  }
}

# V1 — Folder standard list (single-dot constraints only)
resource "google_folder_organization_policy" "list_policies" {
  for_each = local.folder_list_policies_standard

  folder     = each.value.folder_id
  constraint = each.value.constraint

  list_policy {
    inherit_from_parent = each.value.inherit_from_parent
    suggested_value     = each.value.suggested_value

    dynamic "allow" {
      for_each = each.value.status ? [1] : []
      content {
        values = length(each.value.values) > 0 ? each.value.values : null
        all    = length(each.value.values) == 0 ? false : null
      }
    }

    dynamic "deny" {
      for_each = !each.value.status ? [1] : []
      content {
        values = length(each.value.values) > 0 ? each.value.values : null
        all    = length(each.value.values) == 0 ? true : null
      }
    }
  }
}

# V1 — Project standard boolean (single-dot constraints only)
resource "google_project_organization_policy" "boolean_policies" {
  for_each = local.project_boolean_policies_standard

  project    = each.value.project_id
  constraint = each.value.constraint

  boolean_policy {
    enforced = each.value.enforce
  }
}

# V1 — Project standard list (single-dot constraints only)
resource "google_project_organization_policy" "list_policies" {
  for_each = local.project_list_policies_standard

  project    = each.value.project_id
  constraint = each.value.constraint

  list_policy {
    inherit_from_parent = each.value.inherit_from_parent
    suggested_value     = each.value.suggested_value

    dynamic "allow" {
      for_each = each.value.status ? [1] : []
      content {
        values = length(each.value.values) > 0 ? each.value.values : null
        all    = length(each.value.values) == 0 ? false : null
      }
    }

    dynamic "deny" {
      for_each = !each.value.status ? [1] : []
      content {
        values = length(each.value.values) > 0 ? each.value.values : null
        all    = length(each.value.values) == 0 ? true : null
      }
    }
  }
}

# V2 — Managed boolean (.managed. constraints — folder or project)
resource "google_org_policy_policy" "managed_boolean_policies" {
  for_each = local.managed_boolean_policies

  name   = "${each.value.parent}/policies/${each.value.constraint_name}"
  parent = each.value.parent

  spec {
    rules {
      enforce = each.value.enforce ? "TRUE" : "FALSE"
    }
  }
}

# V2 — Managed list (.managed. constraints — folder or project)
resource "google_org_policy_policy" "managed_list_policies" {
  for_each = local.managed_list_policies

  name   = "${each.value.parent}/policies/${each.value.constraint_name}"
  parent = each.value.parent

  spec {
    inherit_from_parent = each.value.inherit_from_parent

    rules {
      dynamic "values" {
        for_each = length(each.value.values) > 0 ? [1] : []
        content {
          allowed_values = each.value.status ? each.value.values : []
          denied_values  = each.value.status ? [] : each.value.values
        }
      }
    }
  }
}
