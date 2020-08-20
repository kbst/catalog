#!/bin/sh

set -e
source_path=$1
target_path=$2
version=$3

# copy install.yaml
cp $source_path/manifests/install.yaml $target_path/normal/install.yaml

# copy namespace-install.yaml
cp $source_path/manifests/namespace-install.yaml $target_path/normal-namespaced/namespace-install.yaml

# copy ha/install.yaml
cp $source_path/manifests/ha/install.yaml $target_path/ha/install.yaml

# copy ha/namespace-install.yaml
cp $source_path/manifests/ha/namespace-install.yaml $target_path/ha-namespaced/namespace-install.yaml
