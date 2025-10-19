users = [
  {
    name           = "test"
    host_nice_name = "nas-dd"
    buckets = {
      replicationtest = {
        read_paths  = ["/"]
        write_paths = ["/uploads"]
      }
    }
  }
]


buckets = [
  {
    name           = "replicationtest"
    region         = "a"
    host_nice_name = "minio-a"

    versioning = {
      enabled = true
    }

    replication = {
      site_a_endpoint  = "http://minio1:9000"
      site_b_endpoint  = "http://minio2:9002"
      region_site_b    = "b"
      site_b_nice_name = "minio-b"
      user_name        = "replication"
      mode             = "two-way"
    }

    lifecycle_rules = [
      {
        id      = "test"
        enabled = true
        noncurrent_expirations = [{
          days           = 1
          newer_versions = 3
        }]
      }
    ]
  }
]


