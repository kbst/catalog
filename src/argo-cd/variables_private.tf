variable "default_variant" {
  type        = string
  description = "The variant to use."
  default     = "ha"

  validation {
    condition = (
      contains(["ha", "ha-namespaced", "normal", "normal-namespaced"], var.default_variant)
    )
    error_message = "Valid values for `default_variant` are `ha`, `ha-namespaced`, `normal` or `normal-namespaced`."
  }
}
