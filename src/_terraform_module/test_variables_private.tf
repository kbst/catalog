variable "default_variant" {
  type        = string
  description = "The variant to use."
  default     = "test_kustomization"

  validation {
    condition = (
      contains(["test_kustomization"], var.default_variant)
    )
    error_message = "The only valid value for `default_variant` is `test_kustomization`."
  }
}
