variable "variant" {
  type        = string
  description = "The variant to use."
  default     = "base"

  validation {
    condition = (
      contains(["base"], var.variant)
    )
    error_message = "Valid values for `variant` are `base`."
  }
}
