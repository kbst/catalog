#!/bin/sh

set -e
source_path=$1
target_path=$2
version=$3

cp $source_path/example/deployment.yaml $target_path/base/deployment.yaml

sed -e "s/<ROLE_NAME>/etcd-operator/g" \
    "${source_path}/example/rbac/cluster-role-template.yaml" \
  > $target_path/clusterwide/cluster_role.yaml
