locals {
  default_tags = {
    managed-by : "terraform"
    repo-url : "https://github.com/soerenschneider/tf-minio"
  }
}

resource "minio_iam_user" "user" {
  name          = var.user_name
  force_destroy = true
  tags          = merge(var.tags, local.default_tags)
}

resource "minio_iam_service_account" "user" {
  target_user   = minio_iam_user.user.name
  update_secret = var.rotate_secret
}
