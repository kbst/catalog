module "configuration" {
  source        = "github.com/kbst/terraform-kubestack//common/configuration?ref=7217deac6f587d9f48fd5f38e79e264861b67709"
  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  # current workspace config
  cfg = lookup(module.configuration.merged, terraform.workspace, {})

  common_annotations = lookup(local.cfg, "common_annotations", null) # != null ? local.cfg["common_annotations"] : null

  common_labels = lookup(local.cfg, "common_labels", null) != null ? local.cfg["common_labels"] : null

  components = lookup(local.cfg, "components", null) != null ? local.cfg["components"] : null

  config_map_generator = lookup(local.cfg, "config_map_generator", null) != null ? local.cfg["config_map_generator"] : []

  crds = lookup(local.cfg, "crds", null) != null ? local.cfg["crds"] : null

  generators = lookup(local.cfg, "generators", null) != null ? local.cfg["generators"] : null

  generator_options = lookup(local.cfg, "generator_options", null) != null ? local.cfg["generator_options"] : null

  images = lookup(local.cfg, "images", null) != null ? local.cfg["images"] : []

  name_prefix = lookup(local.cfg, "name_prefix", null) # != null ? local.cfg["name_prefix"] : null

  namespace = lookup(local.cfg, "namespace", null) # != null ? local.cfg["namespace"] : null

  name_suffix = lookup(local.cfg, "name_suffix", null) # != null ? local.cfg["name_suffix"] : null

  patches = lookup(local.cfg, "patches", null) != null ? local.cfg["patches"] : []

  replicas = lookup(local.cfg, "replicas", null) != null ? local.cfg["replicas"] : []

  secret_generator = lookup(local.cfg, "secret_generator", null) != null ? local.cfg["secret_generator"] : []

  transformers = lookup(local.cfg, "transformers", null) != null ? local.cfg["transformers"] : null

  vars = lookup(local.cfg, "vars", null) != null ? local.cfg["vars"] : []

  variant = lookup(local.cfg, "variant", null) != null ? local.cfg["variant"] : var.variant

  additional_resources = lookup(local.cfg, "additional_resources", null) != null ? local.cfg["additional_resources"] : []
}

output "current_config" {
  value = local.cfg
}
