variable "tf_state_bucket_name" {
  type = string
}

variable "terraform_paths" {
  type        = set(string)
  description = "A set of subdirectories relative to stage directory to write state backend configuration in."
}