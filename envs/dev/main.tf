locals {
  env                          = "dev"
  password_store_paths_default = ["env/${local.env}/minio/serviceaccount/%s"]
}

module "buckets" {
  for_each       = { for bucket in var.buckets : coalesce(bucket.name, bucket.bucket_prefix) => bucket }
  source         = "../../modules/minio_buckets"
  bucket_name    = each.value.name
  bucket_prefix  = each.value.bucket_prefix
  quota          = each.value.quota
  force_destroy  = each.value.force_destroy
  object_locking = each.value.object_locking
  versioning     = each.value.versioning
  ilm_rules      = each.value.ilm
}

module "explicit_users" {
  for_each             = { for user in var.users : user.user_name => user }
  source               = "../../modules/minio_users"
  user_name            = each.key
  policy_statements    = each.value.statements
  rotate_secret        = var.rotate_credentials
  password_store_paths = each.value.password_store_paths
  tags = {
    env   = local.env,
    users = "explicit"
  }
}

module "implicit_users" {
  for_each = {
    for bucket in var.buckets :
    coalesce(bucket.name, bucket.bucket_prefix) =>
    # only add users implicitly if we don't try to create another user explicitly
    bucket if bucket.create_user == true && !contains([for user in var.users : user.user_name], coalesce(bucket.name, bucket.bucket_prefix))
  }
  source    = "../../modules/minio_users"
  user_name = each.key
  policy_statements = [
    {
      preset = each.value.user_role,
      buckets = [
        each.key,
        "${each.key}/*"
      ]
    }
  ]

  password_store_paths = coalesce(each.value.password_store_paths)
  rotate_secret        = var.rotate_credentials
  tags = {
    env   = local.env,
    users = "implicit"
  }
}

module "vault" {
  for_each             = { for sa in merge(module.explicit_users, module.implicit_users) : sa.access_keys.name => sa }
  source               = "../../modules/vault"
  access_keys          = nonsensitive(each.value.access_keys)
  password_store_paths = coalesce(each.value.password_store_paths, local.password_store_paths_default)
}
