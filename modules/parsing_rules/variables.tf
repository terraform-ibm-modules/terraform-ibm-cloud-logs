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
}

variable "cloud_logs_instance_id" {
  type        = string
  description = "The GUID of the existing IBM Cloud Logs instance."
}

variable "cloud_logs_region" {
  type        = string
  description = "The IBM Cloud region where the existing IBM Cloud Logs instance is located."
}

variable "cloud_logs_service_endpoints" {
  type        = string
  description = "The type of service endpoints configured for the existing IBM Cloud Logs instance. Allowed values: public-and-private."
  validation {
    condition     = contains(["public-and-private"], var.cloud_logs_service_endpoints)
    error_message = "The specified cloud_logs_service_endpoints is not a valid selection. Allowed values: public-and-private."
  }
}
