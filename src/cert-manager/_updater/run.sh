#!/bin/sh

set -e
source_path=$1
target_path=$2
version=$3

curl -Lo $target_path/base/cert-manager.yaml https://github.com/jetstack/cert-manager/releases/download/$version/cert-manager.yaml
