################################################################################
# Repository 
################################################################################

variable "repository_name" {
  description = "Name of the repository."
  type        = string
}

variable "repository_image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`. Defaults to `IMMUTABLE`."
  type        = string
  default     = "IMMUTABLE"
}

variable "repository_encryption_type" {
  description = "The encryption type for the repository. Must be one of: `KMS` or `AES256`. Defaults to `AES256`."
  type        = string
  default     = "AES256"
}

variable "repository_kms_key" {
  description = "The ARN of the KMS key to use when encryption_type is `KMS`. If not specified, uses the default AWS managed key for ECR."
  type        = string
  default     = null
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (`true`) or not scanned (`false`)."
  type        = bool
  default     = true
}

variable "repository_force_delete" {
  description = "If `true`, will delete the repository even if it contains images. Defaults to `false`."
  type        = bool
  default     = false
}

################################################################################
# Repository Policy
################################################################################

variable "repository_policy" {
  description = "Manages the ECR repository policy."
  type        = string
  default     = null
}

variable "repository_read_access_arns" {
  description = "The ARNs of the IAM users/roles that have read access to the repository."
  type        = list(string)
  default     = []
}

variable "repository_read_write_access_arns" {
  description = "The ARNs of the IAM users/roles that have read/write access to the repository."
  type        = list(string)
  default     = []
}

###############################################################################
# Lifecycle Policy
################################################################################

variable "lifecycle_policy" {
  description = "Manages the ECR repository lifecycle policy."
  type        = string
  default     = null
}

################################################################################
# Registry Policy
################################################################################

variable "registry_policy" {
  description = "The policy document. This is a JSON formatted string."
  type        = string
  default     = null
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "Add map with ECR tags."
  type        = map(string)
  default     = {}
}
