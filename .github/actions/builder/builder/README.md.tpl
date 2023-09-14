# $title Terraform Module

This module installs $title on Kubernetes.
It is maintained as part of [Kubestack, the Terraform framework for Kubernetes platform engineering](https://www.kubestack.com/).
The module bundles an upstream release of $title and makes it fully configurable with Kustomizations set as input attributes.

## Usage with Kubestack

Kubestack leverages configuration inheritance to avoid drift between environments.
The example below shows how to use the module with Kubestack's default environment names `ops` and `apps`.
You can learn more about [Kubestack's inheritance model in the documentation](https://www.kubestack.com/framework/documentation/inheritance-model/).
For usage instructions without Kubestack see below.

```hcl
terraform {
  required_providers {
    kustomization = {
      source = "kbst/kustomization"
    }
  }
}

provider "kustomization" {
  alias = "local"

  kubeconfig_path = "~/.kube/config"
}

module "example_$module_name" {
  providers = {
    kustomization = kustomization.local
  }

  source  = "kubestack-modules/terraform-kustomization-$name"
  version = "$version"

  configuration = {
    apps = {
      # change the namespace of all resources
      namespace = var.example_argo_cd_namespace
      
      # or add an annotation
      common_annotations = {
        "terraform-workspace" = terraform.workspace
      }
      
      # use images to pull from an internal proxy
      # and avoid being rate limited
      images = [{
        # refers to the 'pod.spec.container.name' to modify the 'image' attribute of
        name     = "container-name"
        
        # customize the 'registry/name' part of the image
        new_name = "reg.example.com/nginx"
      }]
    }

    ops = {
      # scale down replicas in ops
      replicas = [{
        # refers to the 'metadata.name' of the resource to scale
        name = "example"
        
        # sets the desired number of replicas
        count = 1
      }]
    }
  }
}
```

The Kubestack website has more documentation and examples on the available [Kustomization attributes](https://www.kubestack.com/framework/documentation/services/#configuration).

## Usage without Kubestack

Modules are fully usable without Kubestack and without inheritance by setting `configuration_base_key` and a `configuration` with a single key matching your workspace name, e.g. `default`.
The Kubestack website has a complete guide on [how to use the Kubestack modules without the Kubestack framework](https://www.kubestack.com/guides/catalog-using-kubestack-catalog-modules-standalone/).

```hcl
terraform {
  required_providers {
    kustomization = {
      source = "kbst/kustomization"
    }
  }
}

provider "kustomization" {
  alias = "local"

  kubeconfig_path = "~/.kube/config"
}

module "example_$module_name" {
  providers = {
    # we're using the alias provider we configured above
    kustomization = kustomization.local
  }

  source  = "kubestack-modules/terraform-kustomization-$name"
  version = "$version"

  # the configuration here assumes you're using Terraform's default workspace
  # use `terraform workspace list` to see the workspaces
  configuration_base_key = "default"
  configuration = {
    default = {
      replicas = [{
        name  = "example"
        count = 5
      }]
    }
  }
}
```

## Versions

The module versions are the upstream release version (e.g. `v1.5.9`) plus a packaging suffix (e.g. `-kbst.0`).
Should a new module release be necessary without changing the upstream version, the packaging suffix is incremented by one.
Due to the packaging suffix, [Terraform version constraints](https://developer.hashicorp.com/terraform/language/expressions/version-constraints) can not be used for Kubestack modules.

## Contributing

All Kubestack modules are built from the https://github.com/kbst/catalog/ repository.
To contribute please head over to GitHub.
