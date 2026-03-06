locals {
  sa_with_key_iam_bindings = {
    for pair in flatten([
      for sa in var.config.service_accounts_with_key : [
        for role in sa.roles : {
          key        = "${sa.account_id}__${replace(role, "/", "_")}"
          account_id = sa.account_id
          role       = role
        }
      ]
    ]) : pair.key => pair
  }
  sa_without_key_iam_bindings = {
    for pair in flatten([
      for sa in var.config.service_accounts_without_key : [
        for role in sa.roles : {
          key        = "${sa.account_id}__${replace(role, "/", "_")}"
          account_id = sa.account_id
          role       = role
        }
      ]
    ]) : pair.key => pair
  }

  sa_with_key_map    = { for sa in var.config.service_accounts_with_key    : sa.account_id => sa }
  sa_without_key_map = { for sa in var.config.service_accounts_without_key : sa.account_id => sa }
}
