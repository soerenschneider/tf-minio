variable "user_name" {
  type = string

  validation {
    condition     = length(var.user_name) >= 3
    error_message = "User name must be >= 3 characters."
  }
}

variable "policy_statements" {
  type = list(object({
    preset    = optional(string)
    actions   = optional(list(string))
    resources = optional(list(string))
    buckets   = optional(list(string))
  }))

  validation {
    condition = alltrue([
      for s in var.policy_statements : contains(["consoleAdmin", "readwrite", "writeonly", "readonly", "diagnostics"], s.preset)
    ])
    error_message = "If 'preset' is provided, it must be either 'consoleAdmin', 'readwrite', 'writeonly', 'readonly', 'diagnostics'."
  }

  validation {
    condition = alltrue([
      for s in var.policy_statements : (
        (
          length(s.preset) == 0 || try(length(s.actions), 0) == 0
          ) && (
        length(s.preset) != try(length(s.actions), 0))
      )
    ])
    error_message = "Each statement must have either 'preset' or 'actions' set, but not both. One of them must be empty."
  }
}

variable "password_store_paths" {
  type        = list(string)
  description = "Paths to write the credentials to."
}

variable "rotate_secret" {
  type        = bool
  default     = false
  description = "Rotates credentials for all users. Use with caution!"
}

variable "tags" {
  type    = map(any)
  default = {}
}
