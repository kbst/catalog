variable "path" {
  type = string
}

data "kustomization" "test" {
  path = var.path
}

resource "kustomization_resource" "test" {
  for_each = data.kustomization.test.ids

  manifest = data.kustomization.test.manifests[each.value]
}
