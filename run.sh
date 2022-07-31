#!/usr/bin/env bash

# https://betterdev.blog/minimal-safe-bash-script-template/

# Unique key
# Used in setting the bucket name
if [ -z ${KEY+x} ]; then
    if test -f .key; then
        KEY=$(cat .key)
        export KEY
    else
        echo "key is set via neither an env variable or file, exiting..."
        exit 1
    fi
fi

# Used in setting the bucket name
if [ -z ${AWS_ACCOUNT_ID+x} ]; then
    if test -f .aws_account_id; then
        AWS_ACCOUNT_ID=$(cat .aws_account_id)
        export AWS_ACCOUNT_ID
    else
        echo "Account ID is set via neither an env variable or file, exiting..."
        exit 1
    fi
fi

parse_params() {
  COMMAND='plan'
  ENV="testing"

  while :; do
    case "${1-}" in
    -c | --command) 
      COMMAND="${2-}"
      shift
      ;;
    -e | --env) 
      ENV="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  export ENV
    
  return 0
}

parse_params "$@"

set_vars() {
    # Set downloads to a place other than the repo so we don't pollute
    TERRAGRUNT_DOWNLOAD=/tmp/terragrunt/$ENV
    export TERRAGRUNT_DOWNLOAD
    
    TERRAGRUNT_TFPATH=$(pwd)/bin/terraform
    export TERRAGRUNT_TFPATH
    
    TERRAGRUNT_SOURCE_UPDATE=true
    export TERRAGRUNT_SOURCE_UPDATE
    
    TERRAGRUNT_WORKING_DIR=$(pwd)/terraform/workload 
    export TERRAGRUNT_WORKING_DIR
    
    TG_WORKSPACE=$ENV
    export TG_WORKSPACE
    
    AWS_CONFIG_FILE=$(pwd)/.aws/config
    export AWS_CONFIG_FILE
    
    AWS_SHARED_CREDENTIALS_FILE=$(pwd)/.aws/credentials
    export AWS_SHARED_CREDENTIALS_FILE
}

linting() {
  bin/terraform fmt -recursive ./terraform
  bin/terragrunt hclfmt
}

main() {
    set_vars
    linting
    bin/terragrunt ${COMMAND[@]}
}

# Install any dependencies in bin
./scripts/dependencies.sh
main

exit 0
