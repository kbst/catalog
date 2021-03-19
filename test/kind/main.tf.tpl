module "test" {
  source = "{{entry_module}}"

  configuration = {
    apps = {
      variant = "{{variant}}"

      additional_resources = ["${path.module}/test-files/namepsace.yaml"]

      config_map_generator = [
        {
          name      = "test"
          namespace = "test-configuration"
          literals = [
            "test=true"
          ]
        }
      ]
    }
    ops = {}
    loc = {}
  }
}
