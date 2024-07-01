variable "bucket_name" {
  type        = string
  description = "Specifies the name of the bucket to be created in the replication source and replication target"
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "quota" {
  description = "Quota for the bucket in megabytes."
  type        = number
  default     = 0

  validation {
    condition     = var.quota >= 0
    error_message = "Quota must not be negative"
  }
}

variable "object_locking" {
  type    = bool
  default = false
}

variable "bucket_prefix" {
  type    = string
  default = ""
}

variable "public" {
  type    = bool
  default = false
}

variable "versioning" {
  type = object({
    enabled           = bool
    exclude_folders   = optional(bool, false)
    excluded_prefixes = optional(list(string), [])
  })
  default = {
    enabled = false
  }
}

variable "ilm_rules" {
  type = list(object({
    name                               = string
    expiration                         = optional(string)
    filter                             = optional(string)
    noncurrent_version_expiration_days = optional(number)
    noncurrent_version_transition_days = optional(number)
  }))
  default = []
}
