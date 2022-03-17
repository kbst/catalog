#!/bin/sh

set -e
source_path=$1
target_path=$2
version=$3

# copy install.yaml
cp $source_path/manifests/install.yaml $target_path/normal/install.yaml

cd $target_path/normal/

# update version annotation
kustomize edit add annotation -f app.kubernetes.io/version:$version

cd -

# copy ha/install.yaml
cp $source_path/manifests/ha/install.yaml $target_path/ha/install.yaml

cd $target_path/ha/

# update version annotation
kustomize edit add annotation -f app.kubernetes.io/version:$version
