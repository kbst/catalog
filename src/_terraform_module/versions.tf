terraform {
  required_providers {
    kustomization = {
      source  = "kbst/kustomization"
      version = ">= 0.4.1"
    }
  }
  required_version = ">= 0.13"
}
