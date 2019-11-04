# https://storage.googleapis.com/tekton-releases/previous/v0.4.0/release.yaml

#!/bin/sh

set -e
source_path=$1
target_path=$2
version=$3

curl -Lo $target_path/base/release.yaml https://github.com/tektoncd/pipeline/releases/download/$version/release.yaml
