password_store_path = ["soeren.cloud/env/prod/minio/nas.ez.soeren.cloud/%s"]

buckets = [
  {
    name        = "bucket-1",
    create_user = true,

  },
  {
    name = "bucket-2",
    versioning = {
      enabled = true,
    }
    ilm = [
      {
        name       = "default",
        expiration = "7d"
      }
    ]
  }
]

users = [
  {
    user_name = "soeren",
    password_store_paths = [
      "soeren.cloud/env/prod/minio/nas.ez.soeren.cloud/%s"
    ],
    statements = [
      {
        preset = "readwrite",
      }
    ]
  },
  {
    user_name = "bucket-1"
    statements = [
      {
        preset = "readonly",
        resources = [
          "arn:aws:s3:::test"
        ]
        buckets = ["bucket-1"]
      }
    ]
  }
]
