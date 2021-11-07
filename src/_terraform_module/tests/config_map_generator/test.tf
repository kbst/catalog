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
      namespace = "test-cmgen"

      config_map_generator = [
        {
          name     = "test"
          behavior = "merge"
          literals = [
            "${local.test_key}=${local.test_value}"
          ]
          options = {
            annotations = {
              source = "from_base_merged"
            }
          }
        },
        {
          name     = "test-literal"
          behavior = "create"
          literals = [
            "${local.test_key}=${local.test_value}"
          ]
          options = {
            labels = {
              source = "from_literal"
            }
          }
        },
        {
          name = "test-envs"
          envs = [
            "${path.module}/${local.test_file}"
          ]
          options = {
            disable_name_suffix_hash = true
          }
        },
        {
          name = "test-files"
          files = [
            "${path.module}/${local.test_file}"
          ]
        }
      ]
    }

    (terraform.workspace) = {}
  }

  configuration_base_key = "apps"
}

locals {
  manifests = { for k, v in module.mut.manifests : k => jsondecode(v) }
}

//resource "test_assertions" "debug" {
//  component = "config_map_generator"
//
//  equal "value_correct_debug" {
//    description = "key in configmap data has correct value"
//    got         = local.manifests
//    want        = {}
//  }
//}

resource "test_assertions" "from_base_merge" {
  component = "config_map_generator"

  check "key_exists_from_base_merge" {
    description = "key_exists_from_base_merge"
    condition   = contains(keys(local.manifests["_/ConfigMap/test-cmgen/test"].data), local.test_key)
  }

  equal "value_correct_from_base_merge" {
    description = "value_correct_from_base_merge"
    got         = local.manifests["_/ConfigMap/test-cmgen/test"].data[local.test_key]
    want        = local.test_value
  }

  equal "annotation_correct_from_base_merge" {
    description = "annotation_correct_from_base_merge"
    got         = local.manifests["_/ConfigMap/test-cmgen/test"].metadata.annotations["source"]
    want        = "from_base_merged"
  }
}

resource "test_assertions" "from_literal" {
  component = "config_map_generator"

  check "key_exists_from_literal" {
    description = "key_exists_from_literal"
    condition   = contains(keys(local.manifests["_/ConfigMap/test-cmgen/test-literal-cc854d6db8"].data), local.test_key)
  }

  equal "value_correct_from_literal" {
    description = "value_correct_from_literal"
    got         = local.manifests["_/ConfigMap/test-cmgen/test-literal-cc854d6db8"].data[local.test_key]
    want        = local.test_value
  }

  equal "annotation_correct_from_base_merge" {
    description = "annotation_correct_from_base_merge"
    got         = local.manifests["_/ConfigMap/test-cmgen/test-literal-cc854d6db8"].metadata.labels.source
    want        = "from_literal"
  }
}

resource "test_assertions" "from_envs" {
  component = "config_map_generator"

  check "key_exists_from_envs" {
    description = "key_exists_from_envs"
    condition   = contains(keys(local.manifests["_/ConfigMap/test-cmgen/test-envs"].data), upper(local.test_key))
  }

  equal "value_correct_from_envs" {
    description = "value_correct_from_envs"
    got         = local.manifests["_/ConfigMap/test-cmgen/test-envs"].data[upper(local.test_key)]
    want        = local.test_value
  }
}

resource "test_assertions" "from_files" {
  component = "config_map_generator"

  check "key_exists_from_files" {
    description = "key_exists_from_files"
    condition   = contains(keys(local.manifests["_/ConfigMap/test-cmgen/test-files-k7fk56g6g8"].data), local.test_file)
  }

  equal "value_correct_from_files" {
    description = "value_correct_from_files"
    got         = local.manifests["_/ConfigMap/test-cmgen/test-files-k7fk56g6g8"].data[local.test_file]
    want        = file("${path.module}/${local.test_file}")
  }
}
