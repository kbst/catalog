module "configuration" {
  source        = "github.com/kbst/terraform-kubestack//common/configuration?ref=v0.18.0-beta.0"
  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  # current workspace config
  cfg = lookup(module.configuration.merged, terraform.workspace)

  variant = local.cfg["variant"] != null ? local.cfg["variant"] : local.default_variant

  additional_resources = local.cfg["additional_resources"] != null ? local.cfg["additional_resources"] : []
}
