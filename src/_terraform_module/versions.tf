terraform {
  required_providers {
    kustomization = {
      source  = "kbst/kustomization"
      version = ">= 0.5.0"
    }
  }
  required_version = ">= 0.15"
  experiments      = [module_variable_optional_attrs]
}