locals {
    apis_to_enable = [
        "clouderrorreporting.googleapis.com",
        # "networkconnectivity.googleapis.com",
        # "networkmanagement.googleapis.com",
    ]
  
    project_objects = {for p in var.project_objects: p.project_name => merge(p, {
        parent_type = split("/", p.parent)[0],
        parent_id = split("/", p.parent)[1],
        api_services = distinct(concat(local.apis_to_enable, p.services))
        labels = {for k, v in p.labels: k => lower(v)}
    }) if p != null && p.deploy}
    project_services = flatten([
        for p in local.project_objects: [
            for s in p.api_services: merge(p, {service = s, key = "${p.project_name}_${s}"})
        ]
    ])

    project_policies_boolean = flatten([
        for p in local.project_objects: [
            for k, v in p.policy_boolean: merge(p, {constraint_key = k,constraint_value = v,key="${p.project_name}_${k}"})
        ]
    ])
    project_policy_list = flatten([
        for p in local.project_objects: [
            for k, v in p.policy_list: merge(p, {constraint_key = k,constraint_value = v,key="${p.project_name}_${k}"})
        ]
    ])

    service_accounts = flatten([
        for p in local.project_objects: [
            for sa in p.service_accounts: merge(sa, {
                project_name = p.project_name,
                key = "${p.project_name}::${sa.name}"
            }) if p.service_accounts != null
        ]
    ])
    sa_iam_roles = flatten([
        for sa in local.service_accounts: [
            for r in sa.iam_roles: merge(sa, {
                role = r,
                sa_key = sa.key
                project_name = sa.project_name,
                key = "${sa.key}::${r}"
            }) if sa.iam_roles != null && sa.create == true
        ] if sa.create == true
    ])
    ad_groups = flatten([
        for p in local.project_objects: [
            for ad in p.ad_groups: merge(ad, {project_name = p.project_name})
        ]
    ])
    
    ad_iam_roles = flatten([
        for ad in local.ad_groups: [
            for r in ad.iam_roles: merge(ad, {
                role = r,
                member = ad.name
                project_name = ad.project_name,
                key = "${ad.project_name}::${ad.name}::${r}"
            }) if ad.iam_roles != null
        ]
    ])
    budget_alerts = flatten([
        for p in local.project_objects: [
            for t in p.budget.types: [
               for n in t.send_notifications_to: merge(p, {type = t.type,send_notification_to = n, key = "${p.project_name}::${t.type}::${n}"})
            ] if p.budget != null
        ]
    ])
    email  = "email_address"
}
