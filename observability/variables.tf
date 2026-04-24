/**
 * Copyright 2026 Google LLC
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

# ── Module-specific variables ─────────────────────────────────

variable "project_id" {
  description = "ID of the existing GCP project to create monitoring resources in."
  type        = string
}

variable "factories_config" {
  description = "Path to the folder containing observability YAML files."
  type = object({
    observability = optional(string)
  })
  nullable = false
  default  = {}
}

variable "context" {
  description = "Context-specific interpolations."
  type = object({
    bigquery_datasets     = optional(map(string), {})
    condition_vars        = optional(map(map(string)), {})
    custom_roles          = optional(map(string), {})
    email_addresses       = optional(map(string), {})
    folder_ids            = optional(map(string), {})
    iam_principals        = optional(map(string), {})
    kms_keys              = optional(map(string), {})
    log_buckets           = optional(map(string), {})
    notification_channels = optional(map(string), {})
    project_ids           = optional(map(string), {})
    pubsub_topics         = optional(map(string), {})
    storage_buckets       = optional(map(string), {})
    tag_keys              = optional(map(string), {})
    tag_values            = optional(map(string), {})
    vpc_sc_perimeters     = optional(map(string), {})
  })
  default  = {}
  nullable = false
}

# ── Identical to project module variables-observability.tf ────

variable "alerts" {
  description = "Monitoring alerts."
  type = map(object({
    combiner              = string
    display_name          = optional(string)
    enabled               = optional(bool)
    notification_channels = optional(list(string), [])
    severity              = optional(string)
    user_labels           = optional(map(string))
    alert_strategy = optional(object({
      auto_close           = optional(string)
      notification_prompts = optional(list(string))
      notification_rate_limit = optional(object({
        period = optional(string)
      }))
      notification_channel_strategy = optional(object({
        notification_channel_names = optional(list(string))
        renotify_interval          = optional(string)
      }))
    }))
    conditions = optional(list(object({
      display_name = string
      condition_absent = optional(object({
        duration = string
        filter   = optional(string)
        aggregations = optional(list(object({
          per_series_aligner   = optional(string)
          group_by_fields      = optional(list(string))
          cross_series_reducer = optional(string)
          alignment_period     = optional(string)
        })))
        trigger = optional(object({
          count   = optional(number)
          percent = optional(number)
        }))
      }))
      condition_matched_log = optional(object({
        filter           = string
        label_extractors = optional(map(string))
      }))
      condition_monitoring_query_language = optional(object({
        duration                = string
        query                   = string
        evaluation_missing_data = optional(string)
        trigger = optional(object({
          count   = optional(number)
          percent = optional(number)
        }))
      }))
      condition_prometheus_query_language = optional(object({
        query                     = string
        alert_rule                = optional(string)
        disable_metric_validation = optional(bool)
        duration                  = optional(string)
        evaluation_interval       = optional(string)
        labels                    = optional(map(string))
        rule_group                = optional(string)
      }))
      condition_threshold = optional(object({
        comparison              = string
        duration                = string
        denominator_filter      = optional(string)
        evaluation_missing_data = optional(string)
        filter                  = optional(string)
        threshold_value         = optional(number)
        aggregations = optional(list(object({
          per_series_aligner   = optional(string)
          group_by_fields      = optional(list(string))
          cross_series_reducer = optional(string)
          alignment_period     = optional(string)
        })))
        denominator_aggregations = optional(list(object({
          per_series_aligner   = optional(string)
          group_by_fields      = optional(list(string))
          cross_series_reducer = optional(string)
          alignment_period     = optional(string)
        })))
        forecast_options = optional(object({
          forecast_horizon = string
        }))
        trigger = optional(object({
          count   = optional(number)
          percent = optional(number)
        }))
      }))
    })), [])
    documentation = optional(object({
      content   = optional(string)
      mime_type = optional(string)
      subject   = optional(string)
      links = optional(list(object({
        display_name = optional(string)
        url          = optional(string)
      })))
    }))
  }))
  nullable = false
  default  = {}
}

variable "notification_channels" {
  description = "Monitoring notification channels."
  type = map(object({
    type         = string
    description  = optional(string)
    display_name = optional(string)
    enabled      = optional(bool)
    labels       = optional(map(string))
    user_labels  = optional(map(string))
    sensitive_labels = optional(object({
      auth_token  = optional(string)
      password    = optional(string)
      service_key = optional(string)
    }))
  }))
  nullable = false
  default  = {}
}
