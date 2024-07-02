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
      "users/soeren/minio/svcaccount/%s"
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
