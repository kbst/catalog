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
      namespace = "test-secgen"

      secret_generator = [
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
//  component = "secret_generator"
//
//  equal "value_correct_debug" {
//    description = "key in configmap data has correct value"
//    got         = local.manifests
//    want        = {}
//  }
//}

resource "test_assertions" "from_literal" {
  component = "secret_generator"

  check "key_exists_from_literal" {
    description = "key_exists_from_literal"
    condition   = contains(keys(local.manifests["_/Secret/test-secgen/test-literal-9kf247ck92"].data), local.test_key)
  }

  equal "value_correct_from_literal" {
    description = "value_correct_from_literal"
    got         = local.manifests["_/Secret/test-secgen/test-literal-9kf247ck92"].data[local.test_key]
    want        = base64encode(local.test_value)
  }

  equal "annotation_correct_from_base_merge" {
    description = "annotation_correct_from_base_merge"
    got         = local.manifests["_/Secret/test-secgen/test-literal-9kf247ck92"].metadata.labels.source
    want        = "from_literal"
  }
}

resource "test_assertions" "from_envs" {
  component = "secret_generator"

  check "key_exists_from_envs" {
    description = "key_exists_from_envs"
    condition   = contains(keys(local.manifests["_/Secret/test-secgen/test-envs"].data), upper(local.test_key))
  }

  equal "value_correct_from_envs" {
    description = "value_correct_from_envs"
    got         = local.manifests["_/Secret/test-secgen/test-envs"].data[upper(local.test_key)]
    want        = base64encode(local.test_value)
  }
}

resource "test_assertions" "from_files" {
  component = "secret_generator"

  check "key_exists_from_files" {
    description = "key_exists_from_files"
    condition   = contains(keys(local.manifests["_/Secret/test-secgen/test-files-49cdkh47f9"].data), local.test_file)
  }

  equal "value_correct_from_files" {
    description = "value_correct_from_files"
    got         = local.manifests["_/Secret/test-secgen/test-files-49cdkh47f9"].data[local.test_file]
    want        = base64encode(file("${path.module}/${local.test_file}"))
  }
}
