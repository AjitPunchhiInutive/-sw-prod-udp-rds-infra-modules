locals {

  # Filter only secrets where deploy = true
  secrets = {
    for k, v in var.secrets : k => {
      project_id            = v.project_id
      secret_id             = v.secret_id
      labels                = try(v.labels, {})
      annotations           = try(v.annotations, {})
      replication_type      = try(v.replication_type, "auto")
      replication_locations = try(v.replication_locations, [])
      kms_key_name          = try(v.kms_key_name, null)
      rotation_period       = try(v.rotation_period, null)
      next_rotation_time    = try(v.next_rotation_time, null)
      ttl                   = try(v.ttl, null)
      topics                = try(v.topics, [])
    }
    if v.deploy  # ← only deploy when true
  }

  # Flatten secret versions — only for deployed secrets
  secret_versions = {
    for pair in flatten([
      for sk, sv in var.secrets : [
        for vk, vv in try(sv.versions, {}) : {
          key         = "${sk}-${vk}"
          secret_key  = sk
          secret_data = vv.secret_data
          enabled     = try(vv.enabled, true)
        }
      ]
      if sv.deploy
    ]) : pair.key => pair
  }

  # Flatten IAM bindings — only for deployed secrets
  secret_iam_bindings = {
    for pair in flatten([
      for sk, sv in var.secrets : [
        for binding in try(sv.iam_bindings, []) : {
          key        = "${sk}-${binding.role}-${binding.member}"
          secret_key = sk
          project_id = sv.project_id
          role       = binding.role
          member     = binding.member
        }
      ]
      if sv.deploy
    ]) : pair.key => pair
  }
}
