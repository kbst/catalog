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
      common_annotations = {
        "terraform-workspace" = terraform.workspace
      }
    }
  }

  configuration_base_key = terraform.workspace
}

resource "test_assertions" "common_annotations" {
  component = "common_annotations"

  equal "metadata_annotations_is_correct" {
    description = "metadata_annotations_is_correct"
    got         = jsondecode(module.mut.manifests["_/Namespace/_/test"]).metadata.annotations
    want = {
      "terraform-workspace" = terraform.workspace
    }
  }
}
