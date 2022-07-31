#!/usr/bin/env bash

CURR_DIR=$(pwd)
BIN_DIR="$CURR_DIR/bin"
YQ_VERSION="v4.26.1"
YQ_BINARY="yq_linux_amd64"

_yq() {
    tmp_dir=$(mktemp -d)
    pushd "$tmp_dir" || exit 1
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz
    gunzip ${YQ_BINARY}.tar.gz
    tar -xf ${YQ_BINARY}.tar
    cp ${YQ_BINARY} "$BIN_DIR"/yq
    popd || exit 1

    rm -rf "$tmp_dir"
}

aws() {
    VERSION=$(bin/yq '.aws_cli' < versions.yaml)
    tmp_dir=$(mktemp -d)
    pushd "$tmp_dir" || exit 1
    wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-$VERSION.zip"
    unzip "awscli-exe-linux-x86_64-$VERSION.zip"
    ./aws/install -i "$BIN_DIR"/aws-cli -b "$BIN_DIR"
    popd || exit 1

    rm -rf "$tmp_dir"
}

terragrunt() {
    VERSION=$(bin/yq '.terragrunt' < versions.yaml)
    tmp_dir=$(mktemp -d)
    pushd "$tmp_dir" || exit 1
    wget "https://github.com/gruntwork-io/terragrunt/releases/download/$VERSION/terragrunt_linux_amd64"
    chmod +x terragrunt_linux_amd64
    cp terragrunt_linux_amd64 "$BIN_DIR"/terragrunt
    popd || exit 1

    rm -rf "$tmp_dir"
}

terraform() {
    VERSION=$(bin/yq '.terraform' < versions.yaml)
    tmp_dir=$(mktemp -d)
    pushd "$tmp_dir" || exit 1
    wget "https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip"
    unzip "terraform_${VERSION}_linux_amd64.zip"
    cp terraform "$BIN_DIR"/terraform
    popd || exit 1

    rm -rf "$tmp_dir"
}

main() {
    mkdir -p bin
    if ! test -f "$BIN_DIR"/yq; then
        echo "yq not installed, installing..."
        _yq
    fi
    if ! test -f "$BIN_DIR"/aws; then
        echo "aws cli not installed, installing..."
        aws
    fi
    if ! test -f "$BIN_DIR"/terragrunt; then
        echo "terragrunt not installed, installing..."
        terragrunt
    fi
    if ! test -f "$BIN_DIR"/terraform; then
        echo "terraform not installed, installing..."
        terraform
    fi
    if ! test -d venv; then
        python3 -m venv venv
    fi
}

main

exit 0
