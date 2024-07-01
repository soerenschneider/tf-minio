#!/usr/bin/env bash

set -eu

operation="apply"
env="prod"

usage() {
    echo "Usage: $0 [--operation <operation>] [--env <environment>]"
    echo "Options:"
    echo "  --operation, -o  Specify the operation (default: apply) (e.g., start, stop, restart, apply)"
    echo "  --env, -e        Specify the environment (default: prod) (e.g., dev, prod, test)"
    echo "  -h, --help       Display this help message"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--operation)
            operation="$2"
            shift 2
            ;;
        -e|--env)
            env="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

######################################################################

MINIO_SECRET_PATH="infra/selfhosted/dbs/mariadb-${env}"
TF_SECRET_PATH="infra/selfhosted/terraform-state/tf-mariadb-${env}"

echo "Reading opentofu state encryption key..."
OUTPUT=$(pass "${TF_SECRET_PATH}")
_TF_KEY=$(echo "${OUTPUT}" | head -n1)
export _TF_KEY

TF_ENCRYPTION=$(cat <<EOF
key_provider "pbkdf2" "mykey" {
  passphrase = "${_TF_KEY}"
}
EOF
)
export TF_ENCRYPTION

case "$operation" in
    init_upgrade)
        terragrunt --terragrunt-working-dir="envs/${env}" init -upgrade
        ;;
    stop)
        terragrunt --terragrunt-working-dir="envs/${env}" plan
        ;;
    init)
        terragrunt --terragrunt-working-dir="envs/${env}" init
        ;;
    apply)
        echo "Reading credentials credentials..."
        OUTPUT=$(pass "${MINIO_SECRET_PATH}")
        MINIO_USER=$(echo "${OUTPUT}" | grep ^MINIO_USER= | cut -d'=' -f2)
        export MINIO_USER

        MINIO_PASSWORD=$(echo "${OUTPUT}" | grep ^MINIO_PASSWORD= | cut -d'=' -f2)
        export MINIO_PASSWORD

        terragrunt --terragrunt-working-dir="envs/${env}" apply
        ;;
    *)
        echo "Unknown operation: $operation"
        usage
        ;;
esac
