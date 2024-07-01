#!/usr/bin/env bash

set -e

docker-compose down
rm -f terraform.tfstate

TF_ENCRYPTION=$(cat <<EOF
key_provider "pbkdf2" "mykey" {
  passphrase = "somekeynotverysecure"
}
EOF
)
export TF_ENCRYPTION

tofu init

docker-compose up -d

timeout 25 sh -c 'until nc -z $0 $1; do sleep 1; done' 127.0.0.1 9000
timeout 25 sh -c 'until nc -z $0 $1; do sleep 1; done' 127.0.0.1 8200

tofu apply -auto-approve
tofu output users
