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
      images = [
        {
          name     = "busybox"
          new_name = "new_name"
          new_tag  = "new_tag"
        }
      ]
    }
  }

  configuration_base_key = terraform.workspace
}

resource "test_assertions" "images" {
  component = "images"

  equal "image_is_correct" {
    description = "image_is_correct"
    got         = jsondecode(module.mut.manifests["apps/Deployment/test/test"]).spec.template.spec.containers[0].image
    want        = "new_name:new_tag"
  }
}
