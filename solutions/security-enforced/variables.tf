########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key to deploy resources."
  sensitive   = true
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group in which to provision resources to. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
  default     = "Default"
}

variable "prefix" {
  type        = string
  description = "The prefix to add to all resources that this solution creates. To not use any prefix value, you can set this value to `null` or an empty string."
}

variable "region" {
  description = "The IBM Cloud region where Cloud logs instance will be created."
  type        = string
  default     = "us-south"
}

########################################################################################################################
# Cloud Logs
########################################################################################################################

variable "cloud_logs_instance_name" {
  type        = string
  description = "The name of the IBM Cloud Logs instance to create."
  default     = "cloud-logs"
}

variable "cloud_logs_resource_tags" {
  type        = list(string)
  description = "Tags associated with the IBM Cloud Logs instance (Optional, array of strings)."
  default     = []
}

variable "cloud_logs_access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the IBM Cloud Logs instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []
}

variable "cloud_logs_retention_period" {
  type        = number
  description = "The number of days IBM Cloud Logs will retain the logs data in Priority insights. Allowed values: 7, 14, 30, 60, 90."
  default     = 7

  validation {
    condition     = contains([7, 14, 30, 60, 90], var.cloud_logs_retention_period)
    error_message = "Valid values 'cloud_logs_retention_period' are: 7, 14, 30, 60, 90"
  }
}

########################################################################################################################
# COS
########################################################################################################################

variable "existing_cos_instance_crn" {
  type        = string
  description = "The CRN of an existing Object Storage instance."
}

variable "new_logs_cos_bucket_name" {
  type        = string
  nullable    = true
  default     = "cloud-logs-logs-bucket"
  description = "The name of an to be given to a new bucket inside the existing Object Storage instance to use for Cloud Logs."
}

variable "new_metrics_cos_bucket_name" {
  type        = string
  nullable    = true
  default     = "cloud-logs-metrics-bucket"
  description = "The name of an to be given to a new bucket inside the existing Object Storage instance to use for Cloud Logs."
}

########################################################################################################################
# KMS
########################################################################################################################

variable "existing_kms_instance_crn" {
  type        = string
  description = "The CRN of the existing KMS instance (Hyper Protect Crypto Services or Key Protect)."
}

variable "existing_kms_key_crn" {
  type        = string
  default     = null
  description = "The CRN of an existing KMS key to use to encrypt the Cloud Logs Object Storage bucket. If no value is set for this variable and bucket encryption is desired, specify a value for the `existing_kms_instance_crn` variable to create a key ring and key."
}

variable "cloud_log_storage_key_ring" {
  type        = string
  default     = "cos-key-ring"
  description = "The name for the key ring created for the Cloud Logs Object Storage bucket key. Applies only if encryption is desired and if not specifying an existing key. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

variable "cloud_log_storage_key" {
  type        = string
  default     = "cos-key"
  description = "The name for the key created for the Cloud Logs Object Storage bucket. Applies only if encryption is desired and if not specifying an existing key. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

##############################################################################
# Event Notification
##############################################################################

variable "existing_event_notifications_instances" {
  type = list(object({
    en_instance_id      = string
    en_region           = string
    en_integration_name = optional(string)
    skip_en_auth_policy = optional(bool, false)
  }))
  default     = []
  description = "List of Event Notifications instance details for routing critical events that occur in your IBM Cloud Logs."
}

variable "event_notifications_from_email" {
  type        = string
  description = "The `from` email address used in any Security and Compliance Center events coming via Event Notifications."
  default     = "compliancealert@ibm.com"
}

variable "event_notifications_reply_to_email" {
  type        = string
  description = "The `reply_to` email address used in any Security and Compliance Center events coming via Event Notifications."
  default     = "no-reply@ibm.com"
}

variable "event_notifications_email_list" {
  type        = list(string)
  description = "The list of email addresses to notify when Security and Compliance Center triggers an event."
  default     = []
}

##############################################################################
# Logs Routing
##############################################################################

variable "logs_routing_tenant_regions" {
  type        = list(any)
  default     = []
  description = "Pass a list of regions to create a tenant for that is targetted to the Cloud Logs instance created by this module. To manage platform logs that are generated by IBM Cloud® services in a region of IBM Cloud, you must create a tenant in each region that you operate. Leave the list empty if you don't want to create any tenants. NOTE: You can only have 1 tenant per region in an account."
  nullable    = false
}

variable "skip_logs_routing_auth_policy" {
  description = "Whether to create an IAM authorization policy that permits the Logs Routing server 'Sender' access to the IBM Cloud Logs instance created by this module."
  type        = bool
  default     = false
}

#############################################################################################################
# Logs Policies Configuration
#
# logs_policy_name -The name of the IBM Cloud Logs policy to create.
# logs_policy_description - Description of the IBM Cloud Logs policy to create.
# logs_policy_priority - Select priority to determine the pipeline for the logs. High (priority value) sent to 'Priority insights' (TCO pipleine), Medium to 'Analyze and alert', Low to 'Store and search', Blocked are not sent to any pipeline.
# application_rule - Define rules for matching applications to include in the policy configuration.
# subsystem_rule - Define subsystem rules for matching applications to include in the policy configuration.
# log_rules - Define the log severities to include in the policy configuration.
# archive_retention - Define archive retention.
##############################################################################################################

variable "logs_policies" {
  type = list(object({
    logs_policy_name        = string
    logs_policy_description = optional(string, null)
    logs_policy_priority    = string
    application_rule = optional(list(object({
      name         = string
      rule_type_id = string
    })))
    subsystem_rule = optional(list(object({
      name         = string
      rule_type_id = string
    })))
    log_rules = optional(list(object({
      severities = list(string)
    })))
    archive_retention = optional(list(object({
      id = string
    })))
  }))
  description = "Configuration of Cloud Logs policies."
  default     = []

  validation {
    condition     = alltrue([for config in var.logs_policies : (length(config.logs_policy_name) <= 4096 ? true : false)])
    error_message = "Maximum length of logs_policy_name allowed is 4096 chars."
  }

  validation {
    condition     = alltrue([for config in var.logs_policies : contains(["type_unspecified", "type_block", "type_low", "type_medium", "type_high"], config.logs_policy_priority)])
    error_message = "The specified priority for logs policy is not a valid selection. Allowed values are: type_unspecified, type_block, type_low, type_medium, type_high."
  }

  validation {
    condition = alltrue(
      [for config in var.logs_policies :
        (config.application_rule != null ?
          (alltrue([for rule in config.application_rule :
          contains(["unspecified", "is", "is_not", "start_with", "includes"], rule.rule_type_id)]))
        : true)
    ])
    error_message = "Identifier of application_rule 'rule_type_id' is not a valid selection. Allowed values are: unspecified, is, is_not, start_with, includes."
  }

  validation {
    condition = alltrue(
      [for config in var.logs_policies :
        (config.application_rule != null ?
          (alltrue([for rule in config.application_rule :
          can(regex("^[\\p{L}\\p{N}\\p{P}\\p{Z}\\p{S}\\p{M}]+$", rule.name)) && length(rule.name) <= 4096 && length(rule.name) > 1]))
        : true)
    ])
    error_message = "The name of the application_rule does not meet the required criteria."
  }

  validation {
    condition = alltrue(
      [for config in var.logs_policies :
        (config.log_rules != null && length(config.log_rules) > 0 ? true : false)
    ])
    error_message = "The log_rules can not be empty and must contain at least 1 item."
  }

  validation {
    condition = alltrue(
      [for config in var.logs_policies :
        (config.log_rules != null ?
          (alltrue([for rule in config.log_rules :
            alltrue([for severity in rule["severities"] :
          contains(["unspecified", "debug", "verbose", "info", "warning", "error", "critical"], severity)])]))
          : true
    )])
    error_message = "The 'severities' of log_rules is not a valid selection. Allowed values are: unspecified, debug, verbose, info, warning, error, critical."
  }

  validation {
    condition = alltrue(
      [for config in var.logs_policies :
        (config.subsystem_rule != null ?
          (alltrue([for rule in config.subsystem_rule :
          contains(["unspecified", "is", "is_not", "start_with", "includes"], rule.rule_type_id)]))
          : true
    )])
    error_message = "Identifier of subsystem_rule 'rule_type_id' is not a valid selection. Allowed values are: unspecified, is, is_not, start_with, includes."
  }

  validation {
    condition = alltrue(
      [for config in var.logs_policies :
        (config.subsystem_rule != null ?
          (alltrue([for rule in config.subsystem_rule :
          can(regex("^[\\p{L}\\p{N}\\p{P}\\p{Z}\\p{S}\\p{M}]+$", rule.name)) && length(rule.name) <= 4096 && length(rule.name) > 1]))
        : true)
    ])
    error_message = "The name of the subsytem_rule does not meet the required criteria."
  }

  validation {
    condition = alltrue(
      [for config in var.logs_policies :
        (config.archive_retention != null ?
          (alltrue(
            [for rule in config.archive_retention : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", rule.id))]
          )) : true
    )])
    error_message = "The id of the archive_retention does not meet the required criteria."
  }
}
