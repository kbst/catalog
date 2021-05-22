data "kustomization_overlay" "current" {
  common_annotations = local.cfg["common_annotations"]

  common_labels = local.cfg["common_labels"]

  components = local.cfg["components"]

  dynamic "config_map_generator" {
    for_each = local.cfg["config_map_generator"] != null ? local.cfg["config_map_generator"] : []
    iterator = i
    content {
      name      = i.value["name"]
      namespace = i.value["namespace"]
      behavior  = i.value["behavior"]
      envs      = i.value["envs"]
      files     = i.value["files"]
      literals  = i.value["literals"]
      options {
        labels                   = lookup(i.value, "options") != null ? i.value["options"]["labels"] : null
        annotations              = lookup(i.value, "options") != null ? i.value["options"]["annotations"] : null
        disable_name_suffix_hash = lookup(i.value, "options") != null ? i.value["options"]["disable_name_suffix_hash"] : null
      }
    }
  }

  crds = local.cfg["crds"]

  generators = local.cfg["generators"]

  dynamic "generator_options" {
    for_each = local.cfg["generator_options"] != null ? [local.cfg["generator_options"]] : []
    iterator = i
    content {
      labels                   = i.value["labels"]
      annotations              = i.value["annotations"]
      disable_name_suffix_hash = i.value["disable_name_suffix_hash"]
    }
  }

  dynamic "images" {
    for_each = lookup(local.cfg, "images") != null ? lookup(local.cfg, "images") : []
    iterator = i
    content {
      name     = i.value["name"]
      new_name = i.value["new_name"]
      new_tag  = i.value["new_tag"]
      digest   = i.value["digest"]
    }
  }

  name_prefix = local.cfg["name_prefix"]

  namespace = local.cfg["namespace"]

  name_suffix = local.cfg["name_suffix"]

  dynamic "patches" {
    for_each = local.cfg["patches"] != null ? local.cfg["patches"] : []
    iterator = i
    content {
      path   = i.value["path"]
      patch  = i.value["patch"]
      target = i.value["target"]
    }
  }

  dynamic "replicas" {
    for_each = local.cfg["replicas"] != null ? local.cfg["replicas"] : []
    iterator = i
    content {
      name  = i.value["name"]
      count = i.value["count"]
    }
  }

  dynamic "secret_generator" {
    for_each = local.cfg["secret_generator"] != null ? local.cfg["secret_generator"] : []
    iterator = i
    content {
      name      = i.value["name"]
      namespace = i.value["namespace"]
      behavior  = i.value["behavior"]
      type      = i.value["type"]
      envs      = i.value["envs"]
      files     = i.value["files"]
      literals  = i.value["literals"]
      options {
        labels                   = lookup(i.value, "options") != null ? i.value["options"]["labels"] : null
        annotations              = lookup(i.value, "options") != null ? i.value["options"]["annotations"] : null
        disable_name_suffix_hash = lookup(i.value, "options") != null ? i.value["options"]["disable_name_suffix_hash"] : null
      }
    }
  }

  transformers = local.cfg["transformers"]

  dynamic "vars" {
    for_each = local.cfg["vars"] != null ? local.cfg["vars"] : []
    iterator = i
    content {
      name = i.value["name"]
      obj_ref = {
        api_version = lookup(i.value, "obj_ref") != null ? i.value["obj_ref"]["api_version"] : null
        group       = lookup(i.value, "obj_ref") != null ? i.value["obj_ref"]["group"] : null
        version     = lookup(i.value, "obj_ref") != null ? i.value["obj_ref"]["version"] : null
        kind        = lookup(i.value, "obj_ref") != null ? i.value["obj_ref"]["kind"] : null
        name        = lookup(i.value, "obj_ref") != null ? i.value["obj_ref"]["name"] : null
        namespace   = lookup(i.value, "obj_ref") != null ? i.value["obj_ref"]["namespace"] : null
      }
      field_ref = {
        field_path = lookup(i.value, "field_ref") != null ? i.value["field_ref"]["field_path"] : null
      }
    }
  }

  resources = local.cfg["resources"] != null ? local.cfg["resources"] : concat(["${path.module}/${local.variant}/"], local.additional_resources)
}
