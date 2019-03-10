#!/bin/sh

set -e
source_path=$1
target_path=$2
version=$3

cp $source_path/bundle.yaml $target_path/base/bundle.yaml
