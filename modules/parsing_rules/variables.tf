##############################################################################
# Parsing Rules Configuration
#
# parsing_rules - A list of IBM Cloud Logs rule groups to create.
##############################################################################

variable "parsing_rules" {
  type = list(object({
    name        = string
    description = optional(string, null)
    enabled     = optional(bool, true)
    order       = optional(number, null)
    rule_matchers = optional(list(object({
      application_name = optional(object({
        value = string
      }), null)
      subsystem_name = optional(object({
        value = string
      }), null)
      severity = optional(object({
        value = string
      }), null)
    })), [])
    rule_subgroups = list(object({
      enabled = optional(bool, true)
      order   = optional(number, null)
      rules = list(object({
        name         = string
        description  = optional(string, null)
        source_field = string
        enabled      = optional(bool, true)
        order        = optional(number, null)
        parameters = object({
          parse_parameters = optional(object({
            destination_field = string
            rule              = string
          }), null)
          block_parameters = optional(object({
            keep_blocked_logs = bool
            rule              = string
          }), null)
          extract_parameters = optional(object({
            rule = string
          }), null)
          json_extract_parameters = optional(object({
            destination_field = string
          }), null)
          replace_parameters = optional(object({
            destination_field = string
            replace_new_val   = string
            rule              = string
          }), null)
          allow_parameters = optional(object({
            keep_blocked_logs = bool
            rule              = string
          }), null)
          extract_timestamp_parameters = optional(object({
            format   = string
            standard = string
          }), null)
          remove_fields_parameters = optional(object({
            fields = list(string)
          }), null)
          json_stringify_parameters = optional(object({
            destination_field = optional(string, null)
            delete_source     = optional(bool, null)
          }), null)
          json_parse_parameters = optional(object({
            destination_field = optional(string, null)
            delete_source     = optional(bool, null)
            override_dest     = optional(bool, null)
          }), null)
        })
      }))
    }))
  }))
  description = "Configuration of IBM Cloud Logs parsing rule groups."
  default     = []
  validation {
    condition     = alltrue([for rule_group in var.parsing_rules : can(regex("^[\\p{L}\\p{N}\\p{P}\\p{Z}\\p{S}\\p{M}]+$", rule_group.name)) && length(rule_group.name) >= 1 && length(rule_group.name) <= 255])
    error_message = "Each parsing rule group name must be between 1 and 255 characters and match the pattern ^[\\p{L}\\p{N}\\p{P}\\p{Z}\\p{S}\\p{M}]+$."
  }

  validation {
    condition     = alltrue([for rule_group in var.parsing_rules : rule_group.order == null || (rule_group.order >= 0 && rule_group.order <= 4294967295)])
    error_message = "Each parsing rule group order must be between 0 and 4294967295."
  }

  validation {
    condition = alltrue([
      for rule_group in var.parsing_rules :
      alltrue([
        for matcher in rule_group.rule_matchers :
        try(matcher.severity, null) == null || contains(["debug_or_unspecified", "verbose", "info", "warning", "error", "critical"], try(matcher.severity.value, ""))
      ])
    ])
    error_message = "Each rule matcher severity value must be one of: debug_or_unspecified, verbose, info, warning, error, critical."
  }

  validation {
    condition = alltrue([
      for rule_group in var.parsing_rules :
      alltrue([
        for subgroup in rule_group.rule_subgroups :
        alltrue([
          for rule in subgroup.rules :
          try(rule.parameters.json_extract_parameters, null) == null || contains(["category_or_unspecified", "classname", "methodname", "threadid", "severity"], try(rule.parameters.json_extract_parameters.destination_field, ""))
        ])
      ])
    ])
    error_message = "Each json_extract_parameters destination_field must be one of: category_or_unspecified, classname, methodname, threadid, severity."
  }

  validation {
    condition = alltrue([
      for rule_group in var.parsing_rules :
      alltrue([
        for subgroup in rule_group.rule_subgroups :
        alltrue([
          for rule in subgroup.rules :
          try(rule.parameters.extract_timestamp_parameters, null) == null || (
            length(try(rule.parameters.extract_timestamp_parameters.format, "")) >= 1 &&
            length(try(rule.parameters.extract_timestamp_parameters.format, "")) <= 4096 &&
            contains(["strftime_or_unspecified", "javasdf", "golang", "secondsts", "millits", "microts", "nanots"], try(rule.parameters.extract_timestamp_parameters.standard, ""))
          )
        ])
      ])
    ])
    error_message = "Each extract_timestamp_parameters format must be 1–4096 characters, and standard must be one of: strftime_or_unspecified, javasdf, golang, secondsts, millits, microts, nanots."
  }
}

variable "cloud_logs_instance_id" {
  type        = string
  description = "The GUID of the existing IBM Cloud Logs instance."
}

variable "cloud_logs_region" {
  type        = string
  description = "The IBM Cloud region where the existing IBM Cloud Logs instance is located."
}

variable "cloud_logs_endpoint_type" {
  type        = string
  description = "The endpoint type to use to communicate with the existing IBM Cloud Logs instance. Allowed values: public, private."
  validation {
    condition     = contains(["public", "private"], var.cloud_logs_endpoint_type)
    error_message = "The specified cloud_logs_endpoint_type is not a valid selection. Allowed values: public, private."
  }
}
