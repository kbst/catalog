variable "default_variant" {
  type        = string
  description = "The variant to use."
  default     = "clusterwide"

  validation {
    condition = (
      contains(["base", "clusterwide"], var.default_variant)
    )
    error_message = "Valid values for `default_variant` are `base` or `clusterwide`."
  }
}
