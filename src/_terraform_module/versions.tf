terraform {
  required_providers {
    kustomization = {
      source  = "kbst/kustomization"
      version = ">= 0.9.0"
    }
  }

  required_version = ">= 1.3.0"
}
