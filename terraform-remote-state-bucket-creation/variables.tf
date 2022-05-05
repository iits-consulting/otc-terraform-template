variable "stage" {
  type = string
  description = "Current Stage you are working on for example dev,qa, prod etc."
}

variable "context" {
  type = string
  description = "Current Context you are working on can be customer name or cloud name etc."
}

variable "region" {
  type        = string
  description = "OTC region for the project: eu-de(default) or eu-nl"
  default     = "eu-de"
  validation {
    condition     = contains(["eu-de", "eu-nl"], var.region)
    error_message = "Allowed values for region are \"eu-de\" and \"eu-nl\"."
  }
}
