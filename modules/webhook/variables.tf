##############################################################################
# Event Notification
##############################################################################

variable "cloud_logs_region" {
  description = "The IBM Cloud region where Cloud logs instance is created."
  type        = string
  default     = "us-south"
}

variable "cloud_logs_instance_id" {
  type        = string
  description = "The guid of the cloud logs instance."
}

variable "cloud_logs_instance_name" {
  type        = string
  description = "The name of the IBM Cloud Logs instance that is created."
}

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
