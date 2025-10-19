terraform {
  required_version = ">= 1.7.0"
  required_providers {
    minio = {
      source  = "registry.terraform.io/aminueza/minio"
      version = "3.8.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "5.3.0"
    }
  }
}

provider "minio" {
  minio_server   = "localhost:9000"
  minio_user     = "minioadmin"
  minio_password = "minioadmin"
  minio_ssl      = false
}

provider "minio" {
  alias          = "site_b"
  minio_server   = "localhost:9002"
  minio_user     = "minioadmin"
  minio_password = "minioadmin"
  minio_ssl      = false
}

provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = "test"
}
