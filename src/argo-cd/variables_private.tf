variable "variant" {
  type        = string
  description = "The variant to use."
  default     = "ha"

  validation {
    condition = (
      contains(["ha", "ha-namespaced", "normal", "normal-namespaced"], var.variant)
    )
    error_message = "Valid values for `variant` are `ha`, `ha-namespaced`, `normal` or `normal-namespaced`."
  }
}
