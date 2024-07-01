locals {
  presets = {
    consoleAdmin = [
      "s3:*",
      "admin:*"
    ]
    readwrite = [
      "s3:*"
    ]
    writeonly = [
      "s3:PutObject"
    ]
    readonly = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket"
    ],
    diagnostics = [
      "admin:ServerTrace",
      "admin:Profiling",
      "admin:ConsoleLog",
      "admin:ServerInfo",
      "admin:TopLocksInfo",
      "admin:OBDInfo",
      "admin:BandwidthMonitor",
      "admin:Prometheus"
    ]
  }
}

locals {
  resources_default = "arn:aws:s3:::*"
}

data "minio_iam_policy_document" "policy" {
  dynamic "statement" {
    for_each = var.policy_statements
    content {
      actions = coalesce(statement.value["actions"], local.presets[statement.value["preset"]])
      resources = toset(
        coalescelist(
          concat(
            # 1. first concat resources and buckets
            coalesce(statement.value["resources"], []),
            [
              for bucket in coalesce(statement.value["buckets"], []) : "arn:aws:s3:::${bucket}"
            ],
            [
              for bucket in coalesce(statement.value["buckets"], []) : "arn:aws:s3:::${bucket}/*"
            ]
          ),
          # 2. if they're both empty, use the default resource
          [local.resources_default]
        )
      )
    }
  }
}

resource "minio_iam_policy" "policy" {
  name   = "user-${var.user_name}"
  policy = data.minio_iam_policy_document.policy.json
}

resource "minio_iam_user_policy_attachment" "attachment" {
  user_name   = minio_iam_user.user.id
  policy_name = minio_iam_policy.policy.id
}
