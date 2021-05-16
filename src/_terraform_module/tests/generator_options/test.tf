terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

locals {
  test_key   = "test"
  test_value = "value"

  test_file = "env"
}

module "mut" {
  source = "../.."

  configuration = {
    apps = {
      namespace = "test-genopts"

      generator_options = {
        annotations = {
          (local.test_key) = local.test_value
        }

        labels = {
          (local.test_key) = local.test_value
        }

        disable_name_suffix_hash = true
      }

      config_map_generator = [
        {
          name     = "test-literal"
          behavior = "create"
          literals = []
        },
      ]

      secret_generator = [
        {
          name     = "test-literal"
          behavior = "create"
          literals = []
        },
      ]
    }

    (terraform.workspace) = {}
  }

  configuration_base_key = "apps"
}

locals {
  manifests = { for k, v in module.mut.manifests : k => jsondecode(v) }
}

resource "test_assertions" "configmap" {
  component = "generator_options"

  check "cm_has_no_name_suffix" {
    description = "cm_has_no_name_suffix"
    condition   = contains(keys(local.manifests), "~G_v1_ConfigMap|test-genopts|test-literal")
  }

  equal "cm_annotation_correct" {
    description = "cm_annotation_correct"
    got         = local.manifests["~G_v1_ConfigMap|test-genopts|test-literal"].metadata.annotations[local.test_key]
    want        = local.test_value
  }

  equal "cm_labels_correct" {
    description = "cm_labels_correct"
    got         = local.manifests["~G_v1_ConfigMap|test-genopts|test-literal"].metadata.labels[local.test_key]
    want        = local.test_value
  }
}

resource "test_assertions" "secret" {
  component = "generator_options"

  check "secret_has_no_name_suffix" {
    description = "secret_has_no_name_suffix"
    condition   = contains(keys(local.manifests), "~G_v1_Secret|test-genopts|test-literal")
  }

  equal "secret_annotation_correct" {
    description = "secret_annotation_correct"
    got         = local.manifests["~G_v1_Secret|test-genopts|test-literal"].metadata.annotations[local.test_key]
    want        = local.test_value
  }

  equal "secret_labels_correct" {
    description = "secret_labels_correct"
    got         = local.manifests["~G_v1_Secret|test-genopts|test-literal"].metadata.labels[local.test_key]
    want        = local.test_value
  }
}
