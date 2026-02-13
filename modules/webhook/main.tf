##############################################################################
# EN Integration
##############################################################################

# Create IAM Authorization Policies to allow Cloud Logs to access event notification
resource "ibm_iam_authorization_policy" "en_policy" {
  for_each                    = { for idx, en in var.existing_event_notifications_instances : idx => en if !en.skip_iam_auth_policy }
  source_service_name         = "logs"
  source_resource_instance_id = var.cloud_logs_instance_id
  target_service_name         = "event-notifications"
  target_resource_instance_id = split(":", each.value.crn)[7]
  roles                       = ["Event Source Manager", "Viewer"]
  description                 = "Allow Cloud Logs with instance ID ${var.cloud_logs_instance_id} 'Event Source Manager' and 'Viewer' role access on the Event Notification instance GUID ${split(":", each.value.crn)[7]}"
}

resource "time_sleep" "wait_for_en_authorization_policy" {
  depends_on      = [ibm_iam_authorization_policy.en_policy]
  create_duration = "30s"
}

resource "ibm_logs_outgoing_webhook" "en_integration" {
  depends_on    = [time_sleep.wait_for_en_authorization_policy]
  for_each      = { for idx, en in var.existing_event_notifications_instances : idx => en }
  instance_id   = var.cloud_logs_instance_id
  region        = var.cloud_logs_region
  endpoint_type = var.cloud_logs_endpoint_type
  name          = each.value.integration_name == null ? "${var.cloud_logs_instance_name}-en-integration-${each.key}" : each.value.integration_name
  type          = "ibm_event_notifications"

  ibm_event_notifications {
    event_notifications_instance_id = split(":", each.value.crn)[7]
    region_id                       = split(":", each.value.crn)[5]
    endpoint_type                   = var.en_integration_endpoint_type
  }
}
