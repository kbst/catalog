#!/bin/sh

set -e
source_path=$1
target_path=$2
tag=$3

cp $source_path/deploy/static/mandatory.yaml $target_path/base/mandatory.yaml

# fix upstream manifests using master as image tag
cd $target_path/base
# upstream uses nginx- prefixed git tags, but no prefix for image tags
image_tag=$(echo "$tag" | sed -e "s/^nginx-//")
kustomize edit set image quay.io/kubernetes-ingress-controller/nginx-ingress-controller:$image_tag
