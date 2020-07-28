#!/bin/sh

set -e
source_path=$1
target_path=$2

cp $source_path/deploy/static/provider/cloud/deploy.yaml $target_path/base/mandatory.yaml
