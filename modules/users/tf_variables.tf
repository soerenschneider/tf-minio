variable "user_name" {
  description = "Username for the IAM user"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.user_name))
    error_message = "user_name may only contain lowercase letters, numbers and hyphens (-)."
  }

  validation {
    condition     = length(var.user_name) >= 3
    error_message = "user_name needs to have a length of at least 3."
  }
}

variable "buckets" {
  type = map(object({
    read_paths  = optional(list(string), ["/"])
    write_paths = optional(list(string), ["/"])
  }))

  validation {
    condition = alltrue([
      for bucket_name, config in var.buckets :
      length(bucket_name) >= 3 && length(bucket_name) <= 63
    ])
    error_message = "All bucket names must be between 3 and 63 characters long."
  }

  validation {
    condition = alltrue([
      for bucket_name, config in var.buckets :
      can(regex("^[a-z0-9][a-z0-9\\-\\.]*[a-z0-9]$", bucket_name))
    ])
    error_message = "Bucket names must start and end with a lowercase letter or number, and contain only lowercase letters, numbers, hyphens, and dots."
  }

  validation {
    condition = alltrue([
      for bucket_name, config in var.buckets :
      bucket_name != "*"
    ])
    error_message = "Bucket names cannot be wildcards (*)."
  }

  validation {
    condition = alltrue(flatten([
      for bucket_name, config in var.buckets : [
        for path in config.read_paths :
        path != "*"
      ]
    ]))
    error_message = "read_paths cannot contain wildcard (*) values."
  }

  validation {
    condition = alltrue(flatten([
      for bucket_name, config in var.buckets : [
        for path in config.write_paths :
        path != "*"
      ]
    ]))
    error_message = "write_paths cannot contain wildcard (*) values."
  }

  validation {
    condition = alltrue([
      for bucket_name, config in var.buckets :
      length(config.read_paths) > 0 || length(config.write_paths) > 0
    ])
    error_message = "At least one of read_paths or write_paths must be non-empty for each bucket."
  }
}

variable "force_destroy" {
  description = "Whether to force destroy user even if it has access keys"
  type        = bool
  default     = true
}

variable "host_nice_name" {
  type        = string
  description = "This variable is used to build Vault's KV2 secret path where the access credentials are written to."

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.host_nice_name))
    error_message = "host_nicename may only contain lowercase letters, numbers and hyphens (-)."
  }
}

variable "password_store_paths" {
  type        = list(string)
  description = "Paths to write the credentials to."

  validation {
    condition = alltrue([
      for path in var.password_store_paths : length(regexall("%s", path)) == 2
    ])
    error_message = "Each path must contain exactly two occurrences of '%s'."
  }
}
