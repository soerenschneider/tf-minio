output "bucket_names" {
  value = {
    for bucket in module.buckets : bucket.name => bucket
  }
}

output "users" {
  value = {
    for user in merge(module.implicit_users, module.explicit_users) : user.access_keys.name => user.access_keys
  }
  sensitive = true
}

