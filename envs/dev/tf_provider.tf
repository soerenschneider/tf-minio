terraform {
  required_version = ">= 1.7.0"
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "2.3.2"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "4.2.0"
    }
  }

  encryption {
    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.mykey
    }

    state {
      enforced = true
      method   = method.aes_gcm.default
    }
    plan {
      method   = method.aes_gcm.default
      enforced = true
    }
  }
}

provider "vault" {
  address = "http://localhost:8200"
  #checkov:skip=CKV_SECRET_6:local dev environment
  token = "test"
}

provider "minio" {
  minio_user = "hackme"
  #checkov:skip=CKV_SECRET_6:local dev environment
  minio_password = "becauseiforgottochangethepassword"
  minio_server   = "localhost:9000"
}
