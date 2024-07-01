locals {
  versioning_enabled  = "Enabled"
  versioning_disabled = "Suspended"
  acl_public          = "public"
  acl_private         = "private"
}

resource "minio_s3_bucket" "bucket" {
  bucket         = var.bucket_name
  acl            = var.public ? local.acl_public : local.acl_private
  force_destroy  = var.force_destroy
  quota          = var.quota != null ? 1024 * 1024 * var.quota : null
  object_locking = var.object_locking
  bucket_prefix  = var.bucket_prefix
}

resource "minio_s3_bucket_versioning" "bucket" {
  depends_on = [minio_s3_bucket.bucket]
  bucket     = minio_s3_bucket.bucket.bucket

  versioning_configuration {
    status            = var.versioning.enabled ? local.versioning_enabled : local.versioning_disabled
    exclude_folders   = var.versioning.exclude_folders
    excluded_prefixes = var.versioning.excluded_prefixes
  }
}

resource "minio_ilm_policy" "bucket-lifecycle-rules" {
  count  = length(var.ilm_rules) > 0 ? 1 : 0
  bucket = minio_s3_bucket.bucket.bucket

  dynamic "rule" {
    for_each = { for rule in coalesce(var.ilm_rules, []) : rule.name => rule }
    content {
      id                                 = rule.value["name"]
      expiration                         = rule.value["expiration"]
      filter                             = rule.value["filter"]
      noncurrent_version_expiration_days = rule.value["noncurrent_version_expiration_days"]
      noncurrent_version_transition_days = rule.value["noncurrent_version_transition_days"]
    }
  }
}
