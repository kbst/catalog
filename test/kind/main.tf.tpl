module "test" {
  source = "{{entry_module}}"

  configuration = {
    apps = {
      variant = "{{variant}}"
    }

    ops = {}
    
    default = {}
  }
}
