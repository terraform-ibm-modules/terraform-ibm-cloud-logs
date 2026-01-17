variable "region" {
  description = "The IBM Cloud region where IBM Cloud logs instance will be created."
  type        = string
  default     = "us-south"
}

variable "resource_group_id" {
  type        = string
  description = "The id of the IBM Cloud resource group where the instance will be created."
  default     = null
}

variable "instance_name" {
  type        = string
  description = "The name of the IBM Cloud Logs instance to create. Defaults to 'cloud-logs-<region>'"
  default     = null
}

variable "plan" {
  type        = string
  description = "The IBM Cloud Logs plan to provision. Available: standard"
  default     = "standard"

  validation {
    condition = anytrue([
      var.plan == "standard",
    ])
    error_message = "The plan value must be one of the following: standard."
  }
}

variable "resource_tags" {
  type        = list(string)
  description = "Add user resource tags to the Cloud Logs instance to organize, track, and manage costs. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#tag-types)."
  default     = []

  validation {
    condition     = alltrue([for tag in var.resource_tags : can(regex("^[A-Za-z0-9 _\\-.:]{1,128}$", tag))])
    error_message = "Each resource tag must be 128 characters or less and may contain only A-Z, a-z, 0-9, spaces, underscore (_), hyphen (-), period (.), and colon (:)."
  }
}

variable "access_tags" {
  type        = list(string)
  description = "Add existing access management tags to the Cloud Logs instance to manage access. Before you can attach your access management tags you need to create them first. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console)."
  default     = []

  validation {
    condition     = alltrue([for tag in var.access_tags : can(regex("^[A-Za-z0-9 _\\-.]{1,128}:[A-Za-z0-9 _\\-.]{1,128}$", tag))])
    error_message = "Each access tag must be in the format key:value using only A-Z, a-z, 0-9, spaces, underscore (_), hyphen (-), period (.), and colon (:). Exactly one colon is required."
  }
}

variable "retention_period" {
  type        = number
  description = "The number of days IBM Cloud Logs will retain the logs data in Priority insights. Allowed values: 7, 14, 30, 60, 90."
  default     = 7

  validation {
    condition     = contains([7, 14, 30, 60, 90], var.retention_period)
    error_message = "Valid values 'retention_period' are: 7, 14, 30, 60, 90"
  }
}

variable "data_storage" {
  type = object({
    logs_data = optional(object({
      enabled              = optional(bool, false)
      bucket_crn           = optional(string)
      bucket_endpoint      = optional(string)
      skip_cos_auth_policy = optional(bool, false)
    }), {})
    metrics_data = optional(object({
      enabled              = optional(bool, false)
      bucket_crn           = optional(string)
      bucket_endpoint      = optional(string)
      skip_cos_auth_policy = optional(bool, false)
    }), {})
    }
  )
  default = {
    logs_data    = null,
    metrics_data = null
  }
  validation {
    condition     = (var.data_storage.logs_data.bucket_crn == null && var.data_storage.metrics_data.bucket_crn == null) || (var.data_storage.logs_data.bucket_crn != var.data_storage.metrics_data.bucket_crn)
    error_message = "The same bucket cannot be used as both your data bucket and your metrics bucket."
  }
  validation {
    error_message = "`bucket_crn` and `bucket_endpoint` must be included if logs_data `enabled` is true."
    condition = (
      lookup(var.data_storage.logs_data, "enabled", null) == null
      ) || (
      lookup(var.data_storage.logs_data, "enabled", false) == false
      ) || (
      lookup(var.data_storage.logs_data, "bucket_crn", null) != null &&
      lookup(var.data_storage.logs_data, "bucket_endpoint", null) != null &&
      lookup(var.data_storage.logs_data, "enabled", false) == true
    )
  }
  validation {
    error_message = "`bucket_crn` and `bucket_endpoint` must be included if metrics_data `enabled` is true."
    condition = (
      lookup(var.data_storage.metrics_data, "enabled", null) == null
      ) || (
      lookup(var.data_storage.metrics_data, "enabled", false) == false
      ) || (
      lookup(var.data_storage.metrics_data, "bucket_crn", null) != null &&
      lookup(var.data_storage.metrics_data, "bucket_endpoint", null) != null &&
      lookup(var.data_storage.metrics_data, "enabled", false) == true
    )
  }
  description = "A logs data bucket and a metrics bucket in IBM Cloud Object Storage to store your IBM Cloud Logs data for long term storage, search, analysis and alerting."
}

variable "service_endpoints" {
  description = "The type of the service endpoint that will be set for the IBM Cloud Logs instance. Allowed values: public-and-private."
  type        = string
  default     = "public-and-private"
  validation {
    condition     = contains(["public-and-private"], var.service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection. Allowed values: public-and-private."
  }
}

##############################################################################
# Event Notification
##############################################################################

variable "existing_event_notifications_instances" {
  type = list(object({
    crn                  = string
    integration_name     = optional(string)
    skip_iam_auth_policy = optional(bool, false)
  }))
  default     = []
  description = "List of Event Notifications instance details for routing critical events that occur in your IBM Cloud Logs."
}

##############################################################################
# Logs Routing
##############################################################################

variable "logs_routing_tenant_regions" {
  type        = list(any)
  default     = []
  description = "Pass a list of regions to create a tenant for that is targeted to the IBM Cloud Logs instance created by this module. To manage platform logs that are generated by IBM Cloud® services in a region of IBM Cloud, you must create a tenant in each region that you operate. Leave the list empty if you don't want to create any tenants. NOTE: You can only have 1 tenant per region in an account."
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
# logs_policy_priority - Select priority to determine the pipeline for the logs. High (priority value) sent to 'Priority insights' (TCO pipeline), Medium to 'Analyze and alert', Low to 'Store and search', Blocked are not sent to any pipeline.
# application_rule - Define rules for matching applications to include in the policy configuration.
# subsystem_rule - Define subsystem rules for matching applications to include in the policy configuration.
# log_rules - Define the log severities to include in the policy configuration.
# archive_retention - Define archive retention.
##############################################################################################################

variable "policies" {
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
  description = "Configuration of IBM Cloud Logs policies."
  default     = []
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
    operations = optional(list(object({
      api_types = list(object({
        api_type_id = string
      }))
    })))
  }))
  description = "The context-based restrictions rule to create. Only one rule is allowed."
  default     = []
  # Validation happens in the rule module
  validation {
    condition     = length(var.cbr_rules) <= 1
    error_message = "Only one CBR rule is allowed."
  }
}
