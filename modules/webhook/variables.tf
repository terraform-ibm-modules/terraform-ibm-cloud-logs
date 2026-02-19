##############################################################################
# Event Notification
##############################################################################

variable "cloud_logs_region" {
  description = "The IBM Cloud region where the existing Cloud Logs instance is located."
  type        = string
}

variable "cloud_logs_instance_id" {
  type        = string
  description = "The GUID of the existing IBM Cloud Logs instance."
}

variable "cloud_logs_instance_name" {
  type        = string
  description = "The name of the existing IBM Cloud Logs instance. It is used as a prefix for the outgoing webhook name if the existing_event_notification_instances does not set en_integration_name."
}

variable "existing_event_notifications_instances" {
  type = list(object({
    crn                       = string
    integration_name          = optional(string)
    integration_endpoint_type = optional(string, "default_or_public")
    skip_iam_auth_policy      = optional(bool, false)
    cloud_logs_endpoint_type  = optional(string, "public")
  }))
  description = "List of Event Notifications instance details for routing critical events that occur in your IBM Cloud Logs."

  validation {
    condition = alltrue([
      for en in var.existing_event_notifications_instances :
      contains(["private", "default_or_public"], en.integration_endpoint_type)
    ])
    error_message = "The integration_endpoint_type value must be 'private' or 'default_or_public'."
  }

  validation {
    condition = alltrue([
      for en in var.existing_event_notifications_instances :
      contains(["private", "public"], en.cloud_logs_endpoint_type)
    ])
    error_message = "The cloud_logs_endpoint_type value must be 'private' or 'public'."
  }
}
