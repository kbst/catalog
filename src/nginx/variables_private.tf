variable "variant" {
  type        = string
  description = "The variant to use."
  default     = "base"

  validation {
    condition = (
      contains(["base", "default-ingress", "default-ingress-kind"], var.variant)
    )
    error_message = "Valid values for `variant` are `base`, `default-ingress` or `default-ingress-kind`."
  }
}
