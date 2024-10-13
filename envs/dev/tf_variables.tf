variable "buckets" {
  type = list(object({
    name           = optional(string)
    quota          = optional(number, 0)
    bucket_prefix  = optional(string)
    object_locking = optional(bool)
    force_destroy  = optional(bool)
    versioning = optional(object({
      enabled           = bool
      exclude_folders   = optional(bool, false)
      excluded_prefixes = optional(list(string), [])
      }), {
      enabled = false,
    })
    ilm = optional(list(object({
      name                               = string
      expiration                         = optional(string)
      filter                             = optional(string)
      noncurrent_version_expiration_days = optional(number)
      noncurrent_version_transition_days = optional(number)
    })), [])
    create_user          = optional(bool, false)
    user_role            = optional(string, "readwrite")
    password_store_paths = optional(list(string))
  }))
}

variable "users" {
  type = list(object({
    user_name = string,
    statements = list(object({
      preset    = optional(string)
      resources = optional(list(string))
      buckets   = optional(list(string))
    }))
    password_store_paths = optional(list(string))
  }))
}

variable "rotate_credentials" {
  type        = bool
  default     = false
  description = "Rotates credentials for all users. Use with caution!"
}

variable "password_store_paths" {
  type        = list(string)
  default     = []
  description = "Password storage path"
}
