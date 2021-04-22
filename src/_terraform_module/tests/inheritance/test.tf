terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "mut_upstream" {
  source = "../.."

  configuration = {
    upstream = {
      namespace   = "from-upstream"
      name_prefix = "pre-"
      name_suffix = "-suf"
    }

    (terraform.workspace) = {}
  }

  configuration_base_key = "upstream"
}

resource "test_assertions" "from_upstream" {
  component = "configuration_inheritance_from_upstream"

  equal "namespace_name_changed" {
    description = "namespace_name_changed"
    got         = jsondecode(module.mut_upstream.manifests["~G_v1_Namespace|~X|from-upstream"]).metadata.name
    want        = "from-upstream"
  }

  equal "deployment_has_prefix_and_suffix" {
    description = "deployment_has_prefix_and_suffix"
    got         = jsondecode(module.mut_upstream.manifests["apps_v1_Deployment|from-upstream|pre-test-suf"]).metadata.name
    want        = "pre-test-suf"
  }
}

module "mut_workspace" {
  source = "../.."

  configuration = {
    upstream = {
      namespace = "from-upstream"
    }

    (terraform.workspace) = {
      namespace = "from-workspace"
    }
  }

  configuration_base_key = "upstream"
}

resource "test_assertions" "from_workspace" {
  component = "configuration_overwritten_by_workspace"

  equal "configuration_gets_overwritten_by_workspace" {
    description = "configuration_gets_overwritten_by_workspace"
    got         = jsondecode(module.mut_workspace.manifests["~G_v1_Namespace|~X|from-workspace"]).metadata.name
    want        = "from-workspace"
  }
}
