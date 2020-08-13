#!/bin/sh

set -e
source_path=$1
target_path=$2
version=$3

rm -rf $target_path/base
mkdir -p $target_path/base
cp $source_path/deploy/* $target_path/base/

cd $target_path/base/

# set commonAnnotations
kustomize edit add annotation catalog.kubestack.com/heritage:kubestack.com/catalog/flux,catalog.kubestack.com/variant:base,app.kubernetes.io/version:$version

# set commonLabels
kustomize edit add label app.kubernetes.io/component:controller,app.kubernetes.io/managed-by:kubestack,app.kubernetes.io/name:flux
