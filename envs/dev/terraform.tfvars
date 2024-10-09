password_store_path = ["soeren.cloud/env/prod/minio/nas.ez.soeren.cloud/%s"]

buckets = [
  {
    name        = "bla",
    create_user = true,

  },
  {
    name = "test",
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
    user_name = "bla"
    statements = [
      {
        preset = "readonly",
        resources = [
          "arn:aws:s3:::test"
        ]
        buckets = ["bla"]
      }
    ]
  }
]
