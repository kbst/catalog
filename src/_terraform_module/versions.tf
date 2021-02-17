terraform {
  required_providers {
    kustomization = {
      source  = "kbst/kustomization"
      version = ">= 0.4.0"
    }
  }
  required_version = ">= 0.13"
}
