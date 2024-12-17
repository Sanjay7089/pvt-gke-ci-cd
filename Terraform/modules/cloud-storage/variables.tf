/**
 * Copyright 2022 Google LLC
 *
 * This software is provided as is, without warranty or representation for any use or purpose. 
 * Your use of it is subject to your agreement with Google.
 *     
 */


variable "buckets_obj" {
  description = "List of buckets & IAM permissions"
  type = list(object({
    project            = string
    bucket_name        = string
    location           = optional(string)
    prefix             = optional(string)
    bucket_permissions = optional(map(list(string)))

    conditional_bindings = optional(list(object({
      role        = string
      title       = string
      description = string
      expression  = string
      members     = list(string)
      }))
    )

    versioning           = optional(map(bool))
    encryption_key_names = optional(map(string))

    lifecycle_rules = optional(set(object({
      action    = map(string)
      condition = map(string)
    })))

    admins                   = optional(list(string))
    bucket_admins            = optional(map(string))
    bucket_creators          = optional(map(string))
    bucket_hmac_key_admins   = optional(map(string))
    bucket_policy_only       = optional(map(bool))
    bucket_storage_admins    = optional(map(string))
    bucket_viewers           = optional(map(string))
    cors                     = optional(set(any))
    creators                 = optional(list(string))
    folders                  = optional(map(list(string)))
    force_destroy            = optional(map(bool))
    hmac_key_admins          = optional(list(string))
    labels                   = map(string)
    logging                  = optional(any)
    randomize_suffix         = optional(bool)
    retention_policy         = any
    set_admin_roles          = optional(bool)
    set_creator_roles        = optional(bool)
    set_hmac_key_admin_roles = optional(bool)
    set_storage_admin_roles  = optional(bool)
    set_viewer_roles         = optional(bool)
    storage_admins           = optional(list(string))
    storage_class            = optional(string)
    viewers                  = optional(list(string))
    website                  = optional(map(any))
    }
  ))
  validation {
    condition = length([
      for data in var.buckets_obj : true
    if contains(keys(data.labels), "app") && contains(keys(data.labels), "owner")]) == length(var.buckets_obj)
    error_message = "You must specify callcenter and owner labels in user_labels."
  }
}