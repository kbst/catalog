variable "names" {
  type        = set(string)
  description = "List of entry names to create repositories for."
}

variable "owner" {
  type        = string
  description = "The name of the organization owning the repositories."
  default     = "kubestack-modules"
}
