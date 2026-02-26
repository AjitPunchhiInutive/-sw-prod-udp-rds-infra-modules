/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

 /**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
 variable "project_objects" {
   type = list(object({
      deploy = bool            #(Required) if project needs to be deployed
      project_name = string    #(Required) also referred to project_id. must be unique across GCP
      billing_account = string #(Required) Billing account id.
      labels = map(string)     #(Required) Resource labels.
      deletion_policy = optional(string,"DELETE") #(Optional) The deletion policy for the Project. Setting PREVENT will protect the project against any destroy actions caused by a terraform apply or terraform destroy. Setting ABANDON allows the resource to be abandoned rather than deleted, i.e., the Terraform resource can be deleted without deleting the Project via the Google API. Possible values are: "PREVENT", "ABANDON", "DELETE". Default value is PREVENT. 
      auto_create_network = optional(bool, false) #(Optional) Whether to create the default network for the project, default is false.
      parent = string                             #(Required) Parent folder or organization in 'folders/folder_id' or 'organizations/org_id' format.
      policy_boolean = optional(map(bool), {})    #(Optional) Map of boolean org policies and enforcement value, set value to null for policy restore.
      policy_list = optional(map(object({         #(Optional) Map of list org policies, status is true for allow, false for deny, null for restore. Values can only be used for allow or deny
        inherit_from_parent = bool
        suggested_value     = string
        status              = bool
        values              = list(string)
      })), {})
      services = optional(list(string),[])        #(Required) Service APIs to enable.
      service_config = optional(object({
        disable_on_destroy         = bool
        disable_dependent_services = bool
      }),{
        disable_on_destroy         = true
        disable_dependent_services = true
      })
      # shared_vpc_host_config = optional(bool,false) #(Optional) Configures this project as a Shared VPC host project (mutually exclusive with shared_vpc_service_project).
      # shared_vpc_service_config = optional(object({ #(Optional) Configures this project as a Shared VPC service project (mutually exclusive with shared_vpc_host_config).
      #   attach       = bool
      #   host_project = string
      # }),{
      #   attach       = false
      #   host_project = ""
      # })
      service_accounts = optional(list(object({ #(Optional) list of service accounts to be assigned to the Project.
        create = optional(bool, true)           #(Required) if service account needs to be created 
        name = string                           #(Required) Name of the service account.
        iam_roles = optional(list(string), [])  #(Optional) list of role to be assigned to the service account.
      })), [])
      ad_groups = optional(list(object({ #(Optional) list of AD Groups to be assigned to the Project.
        name = string                    #(Required) Name of the AD Group.
        iam_roles = list(string)         #(Required) list of role to be assigned to the AD Group.
      })), [])
      budget = optional(object({                    #(Optional)
        amount = string,                            #(Required) The budgeted amount for each usage period.
        threshold_rules = list(number)              #(Required) Send an alert when this threshold is exceeded. This is a 1.0-based percentage, so 0.5 = 50%, 0.8 = 80%. Must be >= 0.
        types = list(object({                       #(Required) 
          type = string                             #(Required) The type of the notification channel. This field matches the value of the NotificationChannelDescriptor.type field. See https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.notificationChannelDescriptors/list to get the list of valid values such as "email", "slack", etc…
          send_notifications_to = list(string)
      }))}), {amount = 500,threshold_rules = [0.8, 1.0],types = [{type = "email",send_notifications_to = ["cloudinfrastructure@southwire.com"]}]})
   }))
   validation {
     condition = alltrue([
        for p in var.project_objects: (
          length(p.project_name) <= 30 &&
          !anytrue(flatten([for s in p.service_accounts: [
            for r in s.iam_roles: strcontains(lower(r), "owner")
          ]]))
        )
      ])
      error_message = join("\n", flatten([
        for p in var.project_objects: concat(
          length(p.project_name) > 30 ? [format("Error - Project name length exceeded\n------------------------\nLength: %d\nExcess: %d chars\nFix: Reduce %s by %d character%s",
            length(p.project_name),
            length(p.project_name) - 30,
            length(split("-", p.project_name)) > 4 ? split("-", p.project_name)[3] : split("-", p.project_name)[2],
            length(p.project_name) - 30,
            length(p.project_name) - 30 > 1 ? "s" : ""
        )] : [],
          [
            for s in p.service_accounts: [
              for r in s.iam_roles: format("\nError - Restricted role assigned\n------------------------\nProject: %s\nService Account: %s\nRestricted Role: %s\nIssue: Owner roles are not allowed for security reasons\nAction: Please assign a less privileged role with appropriate permissions",
                p.project_name,
                s.name,
                r
              ) if strcontains(lower(r), "owner")
            ]
          ],
        )
      ]))
   }
 }
