# Kubestack Catalog

This repository holds the source kustomize manifests and build toolchain for
the [Kubestack Kubernetes operators catalog](https://www.kubestack.com).

## Development Workflow

1. Work in a branch named `name-version` e.g. `memcached-v0.0.1`
1. Push your branch to trigger CI/CD or install `cloud-build-local` using e.g. `gcloud components install cloud-build-local` and run:

    ```
    cloud-build-local --config=cloudbuild.yaml \
      --substitutions=_CATALOG_BUCKET_NAME=,TAG_NAME=,BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD) \
      --dryrun=false \
      --write-workspace=_build \
      .
    ```

## Making a Release

1. Create a Git tag in the format `name-version`
   * name must be the name of the catalog entry to release, e.g. `memcached`
   * version must be in format `major.minor.patch` prefixed with a `v`,
     e.g. `v0.0.1`
1. Push the tag to trigger CI/CD
