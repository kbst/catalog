provider "kustomization" {
  kubeconfig_raw = yamlencode({
    apiVersion      = "v1"
    current-context = "test"
    clusters = [
      {
        name = "test"
        cluster = {
          certificate-authority-data = ""
          server                     = "https://127.0.0.1:8080"
        }
      }
    ]
    users = [
      {
        name = "test"
        user = {
          token = ""
        }
      }
    ]
    contexts = [
      {
        name = "test"
        context = {
          cluster = "test"
          user    = "test"
        }
      }
    ]
  })
}
