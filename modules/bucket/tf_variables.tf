variable "bucket_name" {
  type        = string
  description = "Specifies the name of the bucket to be created in the replication source and replication target"

  validation {
    condition     = length(var.bucket_name) >= 3
    error_message = "Bucket name too short."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.bucket_name))
    error_message = "bucket_name may only contain lowercase letters, numbers and hyphens (-)."
  }
}

variable "name_is_prefix" {
  type        = bool
  default = false
  description = "Specifies the name of the bucket is a prefix. In this case, a unique bucket name starting with the given prefix is automatically generated."
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

variable "public" {
  type    = bool
  default = false
}

variable "create_user" {
  type    = bool
  default = true

  description = "Create an implicit user that only has access to this bucket."
}

variable "region" {
  type = string
}

variable "versioning" {
  type = object({
    enabled           = optional(bool, false)
    exclude_folders   = optional(bool, false)
    excluded_prefixes = optional(list(string), [])
  })

  default = {
    enabled = false
  }
}

variable "lifecycle_rules" {
  type = list(object({
    id      = string
    enabled = optional(bool, true)
    prefix  = optional(string, "")
    tags    = optional(map(string), {})

    expiration_days              = optional(number, null)
    expiration_date              = optional(string, null)
    expired_object_delete_marker = optional(bool, false)

    noncurrent_expirations = optional(list(object({
      days           = number
      newer_versions = optional(number, null)
    })), [])

    transitions = optional(list(object({
      days          = optional(number, null)
      date          = optional(string, null)
      storage_class = string
    })), [])

    noncurrent_transitions = optional(list(object({
      days           = number
      storage_class  = string
      newer_versions = optional(number, null)
    })), [])
  }))
  default = []
  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules : (
        (
          rule.expiration_days == null || rule.expiration_days > 0
        ) &&
        alltrue([
          for nc in rule.noncurrent_expirations : nc.days > 0
        ]) &&
        alltrue([
          for t in rule.transitions : t.days == null || t.days > 0
        ]) &&
        alltrue([
          for nct in rule.noncurrent_transitions : nct.days > 0
        ])
      )
    ]) && (length(var.lifecycle_rules) == length(distinct([for r in var.lifecycle_rules : r.id])))

    error_message = <<EOT
All lifecycle rules fields that contain "days" must be greater than 0 (if set):
- expiration_days
- noncurrent_expirations.days
- transitions.days
- noncurrent_transitions.days

Additionally, each lifecycle rule must have a unique 'id'. Duplicate ids are not allowed.
EOT
  }
}

variable "replication" {
  type = object({
    mode                        = string
    enabled                     = optional(bool, true)
    user_name                   = optional(string)
    site_a_endpoint             = optional(string)
    site_b_endpoint             = string
    site_b_nice_name            = string
    region_site_b               = string
    bandwidth_limit             = optional(string, "100M")
    delete_marker_replication   = optional(bool, true)
    delete_replication          = optional(bool, true)
    existing_object_replication = optional(bool, true)
    metadata_sync               = optional(bool, true)
    prefix                      = optional(string)
    priority                    = optional(number, 1)
    tags                        = optional(map(string))
  })

  validation {
    condition     = contains(["", "one-way", "two-way"], var.replication.mode)
    error_message = "Invalid mode. Allowed values are: \"\" (disabled), \"one-way\", or \"two-way\"."
  }

  validation {
    condition = (
      var.replication.mode == "two-way" &&
      var.replication.site_a_endpoint != null &&
      var.replication.site_b_endpoint != null &&
      var.replication.metadata_sync == true
    )
    error_message = "in two-way replication mode, site_a_endpoint, site_b_endpoint must be set and metadata_sync must be true."
  }

  validation {
    condition     = var.replication.mode != "one-way" || var.replication.mode == "one-way" && var.replication.site_b_endpoint != null
    error_message = "in 'one-way' replication, site_b_endpoint must be set."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.replication.site_b_nice_name))
    error_message = "site_b_nice_name may only contain lowercase letters, numbers and hyphens (-)."
  }

  validation {
    condition     = can(regex("^\\d+[KMG]$", var.replication.bandwidth_limit))
    error_message = "Bandwidth limit must start with a number and end with a unit (e.g., '100M')."
  }

  validation {
    condition     = can(regex("^https?://[a-zA-Z0-9._-]+:[0-9]+(/.*)?$", var.replication.site_b_endpoint))
    error_message = "site_b_endpoint must start with http:// or https://, include a hostname, and a port number (e.g., http://example.com:8080)."
  }

  validation {
    condition     = length(var.replication.site_a_endpoint) == 0 || can(regex("^https?://[a-zA-Z0-9._-]+:[0-9]+(/.*)?$", var.replication.site_a_endpoint))
    error_message = "site_a_endpoint must be either empty (for 'one-way' repliaction) or start with http:// or https://, include a hostname, and a port number (e.g., http://example.com:8080)."
  }

  validation {
    condition     = length(var.replication.user_name) == 0 || can(regex("^[a-z0-9_-]+$", var.replication.user_name))
    error_message = "user_name must be either empty or only contain lowercase letters, numbers, hyphens (-)."
  }

  validation {
    condition     = var.replication.priority >= 1
    error_message = "Replication priority must be at least 1."
  }
}

variable "force_destroy" {
  default = false
  type    = bool
}

variable "host_nice_name" {
  type        = string
  description = "This variable is used to build the path where the secret is written to. Only needed if a user is created."

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
