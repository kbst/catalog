#!/bin/sh

set -e
source_path=$1
target_path=$2
version=$3

# concierge
curl -Lo $target_path/concierge-base/crds.yaml https://get.pinniped.dev/$version/install-pinniped-concierge-crds.yaml
curl -Lo $target_path/concierge-base/resources.yaml https://get.pinniped.dev/$version/install-pinniped-concierge-resources.yaml

cd $target_path/concierge-base/

# set commonAnnotations
kustomize edit add annotation -f app.kubernetes.io/version:$version

cd -

# supervisor
curl -Lo $target_path/supervisor-base/resources.yaml https://get.pinniped.dev/$version/install-pinniped-supervisor.yaml

cd $target_path/concierge-base/

# set commonAnnotations
kustomize edit add annotation -f app.kubernetes.io/version:$version
