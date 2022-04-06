terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "mut" {
  source = "../.."

  configuration = {
    (terraform.workspace) = {
      patches = [
        {
          path = "${path.module}/patch_deployment_resources.yaml"
        },
        {
          patch = <<-EOF
            - op: replace
              path: /metadata/name
              value: newname
          EOF
          target = {
            group               = ""
            version             = "v1"
            kind                = "ConfigMap"
            name                = "test"
            namespace           = "test"
            label_selector = "test"
            annotation_selector = "test"
          }
        }
      ]
    }
  }

  configuration_base_key = terraform.workspace
}

locals {
  manifests = { for k, v in module.mut.manifests : k => jsondecode(v) }
}

resource "test_assertions" "patches_deployment_resources" {
  component = "patches_deployment_resources"

  equal "resources_are_correct" {
    description = "resources_are_correct"
    got         = local.manifests["apps/Deployment/test/test"].spec.template.spec.containers[0].resources
    want = {
      limits = {
        cpu    = "100m"
        memory = "100Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "100Mi"
      }
    }
  }
}

resource "test_assertions" "patches_rename_configmap" {
  component = "patches_rename_configmap"

  check "changed_configmap_name_in_manifests" {
    description = "changed_configmap_name_in_manifests"
    condition   = contains(keys(local.manifests), "_/ConfigMap/test/newname")
  }
}
