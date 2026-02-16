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
}
