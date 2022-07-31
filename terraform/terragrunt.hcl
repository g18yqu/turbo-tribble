generate "provider" {
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "${get_env("AWS_ACCOUNT_ID")}-${get_env("KEY")}-turbo-tribble-remote-state"

    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "my-lock-table"

    shared_credentials_file = "${get_env("PWD")}/.aws/credentials"
  }
}
