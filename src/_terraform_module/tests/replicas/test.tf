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
      replicas = [
        {
          name  = "test"
          count = 3
        }
      ]
    }
  }

  configuration_base_key = terraform.workspace
}

resource "test_assertions" "replicas" {
  component = "replicas"

  equal "replicas_is_correct" {
    description = "replicas_is_correct"
    got         = jsondecode(module.mut.manifests["apps/Deployment/test/test"]).spec.replicas
    want        = 3
  }
}
