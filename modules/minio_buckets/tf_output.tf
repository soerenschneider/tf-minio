output "name" {
  value = minio_s3_bucket.bucket.bucket
}

output "url" {
  value = minio_s3_bucket.bucket.bucket_domain_name
}

locals {
  quota_mi = minio_s3_bucket.bucket.quota / 1024 / 1024
}

output "quota" {
  value = "${local.quota_mi}Mi"
}

output "acl" {
  value = minio_s3_bucket.bucket.acl
}
