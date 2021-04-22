variable "default_variant" {
  type        = string
  description = "The variant to use."
  default     = "base"

  validation {
    condition = (
      contains(["base", "default-ingress", "default-ingress-kind"], var.default_variant)
    )
    error_message = "Valid values for `default_variant` are `base`, `default-ingress` or `default-ingress-kind`."
  }
}
