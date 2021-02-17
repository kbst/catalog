variable "variant" {
  type        = string
  description = "The variant to use."
  default     = "clusterwide"

  validation {
    condition = (
      contains(["base", "clusterwide"], var.variant)
    )
    error_message = "Valid values for `variant` are `base` or `clusterwide`."
  }
}
