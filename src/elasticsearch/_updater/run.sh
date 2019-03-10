#!/bin/sh

set -e
source_path=$1
target_path=$2
tag=$3

cp $source_path/example/controller.yaml $target_path/base/controller.yaml

# fix for upstream forgetting to update the image tag
cd $target_path/base
# upstream uses v prefixed git tags, but no v prefix for image tags
image_tag=$(echo "$tag" | sed -e "s/^v//")
kustomize edit set image upmcenterprises/elasticsearch-operator:$image_tag
