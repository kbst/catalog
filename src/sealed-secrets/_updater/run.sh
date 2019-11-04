#!/bin/sh

set -e
source_path=$1
target_path=$2
version=$3

curl -Lo $target_path/base/controller.yaml https://github.com/bitnami-labs/sealed-secrets/releases/download/$version/controller.yaml
