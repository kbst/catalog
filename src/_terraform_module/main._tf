resource "kustomization_resource" "p0" {
  for_each = data.kustomization_overlay.current.ids_prio[0]

  manifest = (
    contains(var.sensitive_group_kinds, regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.current.manifests[each.value])
    : data.kustomization_overlay.current.manifests[each.value]
  )
}

resource "kustomization_resource" "p1" {
  for_each = data.kustomization_overlay.current.ids_prio[1]

  manifest = (
    contains(var.sensitive_group_kinds, regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.current.manifests[each.value])
    : data.kustomization_overlay.current.manifests[each.value]
  )

  depends_on = [kustomization_resource.p0]
}

resource "kustomization_resource" "p2" {
  for_each = data.kustomization_overlay.current.ids_prio[2]

  manifest = (
    contains(var.sensitive_group_kinds, regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.current.manifests[each.value])
    : data.kustomization_overlay.current.manifests[each.value]
  )

  depends_on = [kustomization_resource.p1]
}
