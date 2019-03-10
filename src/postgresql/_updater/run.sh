#!/bin/sh

set -e
source_path=$1
target_path=$2
tag=$3

cp $source_path/manifests/postgres-operator.yaml $target_path/base/postgres-operator.yaml

cp $source_path/manifests/operator-service-account-rbac.yaml $target_path/clusterwide/rbac.yaml

# fix upstream by default exposing db externally
# make base not clusterwide
# and make provider indepented
sed -e 's/enable_master_load_balancer: "true"/enable_master_load_balancer: "false"/g' \
    -e '/watched_namespace/d' \
    -e '/aws_region:/d' \
    "${source_path}/manifests/configmap.yaml" \
  > "${target_path}/base/configmap.yaml"

# fix upstream net setting image correctly in provided manifest
cd $target_path/base
kustomize edit set image registry.opensource.zalan.do/acid/smoke-tested-postgres-operator=registry.opensource.zalan.do/acid/postgres-operator:$tag
