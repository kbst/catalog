# Kubestack Catalog

This repository holds the kustomize source manifests and build toolchain for
the [Kubestack catalog of Kustomize bases](https://www.kubestack.com/catalog).

## Development Workflow

1. Fork this repository
1. Work in a feature branch
1. Validate your changes locally
   ```
   # Build the helper image
   # optional `--build-arg KUSTOMIZE_VERSION=2.1.0`
   docker build -t python3-kustomize .

   # Run dist.py to generate the archives
   docker run \
       --rm \
       -u `id -u`:`id -g` \
       -v `pwd`:/workspace \
       -w /workspace \
       -e GIT_SHA=`git rev-parse --verify HEAD^{commit}` \
       -e GIT_REF=refs/heads/`git rev-parse --abbrev-ref HEAD` \
       python3-kustomize \
       ./dist.py

   # Run test.py to test your changes
   docker run \
       --rm \
       -u `id -u`:`id -g` \
       -v `pwd`:/workspace \
       -w /workspace \
       python3-kustomize \
       ./test.py

   ```
1. Send a pull-request

## Making a Release

1. Create a Git tag in the format `name-version`
   * name must be the name of the catalog entry to release, e.g. `memcached`
   * version must be in format `major.minor.patch` prefixed with a `v`,
     e.g. `v0.0.1`
1. Push the tag to trigger CI/CD
