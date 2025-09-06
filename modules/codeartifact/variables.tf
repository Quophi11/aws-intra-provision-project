# Variables for CodeArtifact module
variable "domain_name" {
  description = "The name of the CodeArtifact domain."
  type        = string
}

variable "repository_name" {
  description = "The name of the CodeArtifact repository."
  type        = string
}

variable "repository_description" {
  description = "Description for the CodeArtifact repository."
  type        = string
  default     = ""
}
