
# added for custom policy
output "custom_constraint_ids" {
  description = "IDs of custom org policy constraints"
  value       = { for k, v in google_org_policy_custom_constraint.custom_policies : k => v.id }
}

# added for custom policy
output "custom_policy_ids" {
  description = "IDs of custom org policy enforcement policies"
  value       = { for k, v in google_org_policy_policy.custom_policies : k => v.id }
}

output "folder_boolean_policy_ids" {
  description = "IDs of folder-level boolean organization policies"
  value       = { for k, v in google_folder_organization_policy.boolean_policies : k => v.id }
}

output "folder_list_policy_ids" {
  description = "IDs of folder-level list organization policies"
  value       = { for k, v in google_folder_organization_policy.list_policies : k => v.id }
}

output "project_boolean_policy_ids" {
  description = "IDs of project-level boolean organization policies"
  value       = { for k, v in google_project_organization_policy.boolean_policies : k => v.id }
}

output "project_list_policy_ids" {
  description = "IDs of project-level list organization policies"
  value       = { for k, v in google_project_organization_policy.list_policies : k => v.id }
}
