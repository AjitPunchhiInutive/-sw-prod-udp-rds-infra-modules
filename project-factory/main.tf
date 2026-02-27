resource "google_project" "self" {
    for_each            = local.project_objects
    org_id              = each.value.parent_type == "organizations" ? each.value.parent_type : null
    folder_id           = each.value.parent_type == "folders" ? each.value.parent_id : null
    project_id          = lower(each.value.project_name)
    name                = each.value.project_name
    billing_account     = each.value.billing_account
    auto_create_network = each.value.auto_create_network
    deletion_policy     = each.value.deletion_policy
    labels              = merge(each.value.labels, {date_created = formatdate("MM-DD-YYYY", timestamp())})
    lifecycle {
      ignore_changes = [ labels["date_created"] ]
    }
}

resource "google_project_service" "self" {
    for_each                   = {for v in local.project_services: v.key => v}
    project                    = google_project.self[each.value.project_name].project_id
    service                    = each.value.service
    disable_on_destroy         = each.value.service_config.disable_on_destroy
    disable_dependent_services = each.value.service_config.disable_dependent_services
    depends_on                 = [null_resource.self ]
}

resource "google_project_organization_policy" "self" {
    for_each   = {for v in local.project_policies_boolean: v.key => v}
    project    = google_project.self[each.value.project_name].project_id
    constraint = each.value.constraint_key

    dynamic "boolean_policy" {
        for_each = each.value.constraint_value == null ? [] : [each.value.constraint_value]
        iterator = policy
        content {
            enforced = policy.value
        }
    }

    dynamic "restore_policy" {
        for_each = each.value.constraint_value == null ? [""] : []
        content {
            default = true
        }
    }
}

resource "google_project_organization_policy" "self_list" {
    for_each   = {for v in local.project_policy_list: v.key => v}
    project    = google_project.self[each.value.project_name].project_id
    constraint = each.value.constraint_key

    dynamic "list_policy" {
        for_each = each.value.constraint_value.status == null ? [] : [each.value.constraint_value]
        iterator = policy
        content {
            inherit_from_parent = policy.value.inherit_from_parent
            suggested_value     = policy.value.suggested_value
            dynamic "allow" {
                for_each = policy.value.status ? [""] : []
                content {
                    values = (
                        try(length(policy.value.values) > 0, false)
                        ? policy.value.values
                        : null
                    )
                    all = (
                        try(length(policy.value.values) > 0, false)
                        ? null
                        : true
                    )
                }
            }
            dynamic "deny" {
                for_each = policy.value.status ? [] : [""]
                content {
                    values = (
                        try(length(policy.value.values) > 0, false)
                        ? policy.value.values
                        : null
                    )
                    all = (
                        try(length(policy.value.values) > 0, false)
                        ? null
                        : true
                    )
                }
            }
        }
    }

    dynamic "restore_policy" {
        for_each = each.value.constraint_value.status == null ? [true] : []
        content {
            default = true
        }
    }
}

resource "null_resource" "self" {
  depends_on = [google_project_organization_policy.self_list]

  provisioner "local-exec" {
    command = "sleep 3"  # Sleep for 3 seconds
  }
}

# resource "google_compute_shared_vpc_host_project" "self" {
#   for_each   = {for k,v in local.project_objects: k => v if v.shared_vpc_host_config}    
#   project    = google_project.self[each.value.project_name].project_id
#   depends_on = [google_project_service.self]
# }

# resource "google_compute_shared_vpc_service_project" "self" {
#   for_each        = {for k,v in local.project_objects: k => v if v.shared_vpc_service_config.attach}
#   host_project    = each.value.shared_vpc_service_config.host_project
#   service_project = google_project.self[each.value.project_name].project_id
#   depends_on      = [null_resource.self]
# }

resource "google_service_account" "self" {
    for_each     = {for v in local.service_accounts: v.key => v if v.create}
    project      = google_project.self[each.value.project_name].project_id
    account_id   = each.value.name
    display_name = "Service account created from project module"
}

resource "google_project_iam_member" "sa" {
    for_each   = {for v in local.sa_iam_roles: v.key => v}
    project    = google_project.self[each.value.project_name].project_id
    role       = each.value.role
    member     = try("serviceAccount:${google_service_account.self[each.value.sa_key].email}", "serviceAccount:${each.value.name}")
    depends_on = [google_service_account.self]
    lifecycle {
    precondition {
      condition = data.google_iam_role.self[each.key].name != null
      error_message = "The specified role ${each.value.role} does not exist. please remove from the list"
    }
  }
}

data "google_iam_role" "self" {
  for_each = {for v in concat(local.ad_iam_roles, local.sa_iam_roles): v.key => v}
  name = each.value.role
}

resource "google_project_iam_member" "ad" {
  for_each = {for v in local.ad_iam_roles: v.key => v}
  project  = google_project.self[each.value.project_name].project_id
  role     = each.value.role
  member   = "group:${each.value.member}"
  lifecycle {
    precondition {
      condition = data.google_iam_role.self[each.key].name != null
      error_message = "The specified role ${each.value.role} does not exist. please remove from the list"
    }
  }
}

resource "google_monitoring_notification_channel" "self" {
    for_each     = {for v in local.budget_alerts: v.key => v}
    display_name = "${each.value.key}_alert_notification"
    type         = each.value.type
    project      = each.value.project_name 
    labels       = {"${local.email}" = each.value.send_notification_to}
    depends_on = [ google_project.self ]
}

resource "google_billing_budget" "self" {
    for_each        = {for k, v in local.project_objects: k => v if v.budget != null}
    depends_on = [ google_project_service.self ]
    billing_account = each.value.billing_account
    display_name    = "${each.value.project_name} Budget Alert"
 
    budget_filter {
        projects = ["projects/${google_project.self[each.value.project_name].number}"]
    }
 
    amount {
        specified_amount {
            currency_code = "USD"
            units         = each.value.budget.amount  # Budget amount in dollars
        }
    }
 
    dynamic "threshold_rules" {
      for_each = each.value.budget.threshold_rules    # Alert at set threshold
      content {
        threshold_percent = threshold_rules.value
      }
    }
 
    all_updates_rule {
        monitoring_notification_channels = flatten([
            for t in each.value.budget.types: [
                for n in t.send_notifications_to: [
                    google_monitoring_notification_channel.self["${each.value.project_name}::${t.type}::${n}"].name 
                ] 
            ]
        ])
    }
}
