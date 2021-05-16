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
      common_labels = {
        "terraform-workspace" = terraform.workspace
      }
    }
  }

  configuration_base_key = terraform.workspace
}

resource "test_assertions" "common_labels" {
  component = "common_labels"

  equal "metadata_labels_are_correct" {
    description = "metadata_labels_are_correct"
    got         = jsondecode(module.mut.manifests["~G_v1_Namespace|~X|test"]).metadata.labels
    want = {
      "terraform-workspace" = terraform.workspace
    }
  }
}
