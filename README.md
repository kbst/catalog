# Catalog

* to be able to run `kustomize build`, first run `dist.py {name}-dev`.
* the command `test.py {name}-dev` will run `kustomize build` to test
* cloudbuild.yaml is used to build and test and finally upload to a Google
  cloud storage bucket
