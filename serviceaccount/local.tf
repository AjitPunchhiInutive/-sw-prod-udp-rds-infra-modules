locals {

  sa_map = {
    for sa in var.config.service_accounts : sa.account_id => sa
    if sa.deploy == true
  }

  sa_iam_bindings = {
    for pair in flatten([
      for sa in var.config.service_accounts : [
        for role in sa.roles : {
          key        = "${sa.account_id}__${replace(role, "/", "_")}"
          account_id = sa.account_id
          role       = role
        }
      ] if sa.deploy == true
    ]) : pair.key => pair
  }
}
