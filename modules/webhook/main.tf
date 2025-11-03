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
  depends_on  = [time_sleep.wait_for_en_authorization_policy]
  for_each    = { for idx, en in var.existing_event_notifications_instances : idx => en }
  instance_id = var.cloud_logs_instance_id
  region      = var.cloud_logs_region
  name        = each.value.integration_name == null ? "${var.cloud_logs_instance_name}-en-integration-${each.key}" : each.value.integration_name
  type        = "ibm_event_notifications"

  ibm_event_notifications {
    event_notifications_instance_id = split(":", each.value.crn)[7]
    region_id                       = split(":", each.value.crn)[5]
  }
}

data "ibm_resource_instance" "secrets_manager_instance" {
  name     = "Secrets Manager-Goldeneye"
  service  = "secrets-manager"
  location = "us-south"
}

data "ibm_sm_secrets" "webhook_arbitrary_secret" {
  instance_id  = data.ibm_resource_instance.secrets_manager_instance.guid
  region       = "us-south"
  search       = "slack-incoming-webhook"
  secret_types = ["arbitrary"]
}


data "ibm_sm_arbitrary_secret" "goldeneye_webhook" {
  instance_id = data.ibm_resource_instance.secrets_manager_instance.guid
  region      = "us-south"
  secret_id   = one([for secret in data.ibm_sm_secrets.webhook_arbitrary_secret.secrets : secret.id])
}

locals {
  goldeneye_slack_webhook_url = data.ibm_sm_arbitrary_secret.goldeneye_webhook.payload
}

resource "ibm_logs_outgoing_webhook" "goldeneye_slack_integration" {
  instance_id = var.cloud_logs_instance_id
  region      = var.cloud_logs_region
  name        = "goldeneye-slack-integration"
  url         = local.goldeneye_slack_webhook_url
  type        = "ibm_event_notifications"
}

resource "ibm_logs_alert" "goldeneye_error_alert" {
  name        = "goldeneye-error-alert"
  instance_id = var.cloud_logs_instance_id
  region      = var.cloud_logs_region
  description = "Alert for error level logs in GoldenEye bot sent to Slack"
  is_active   = true
  severity    = "error"
  condition {
    new_value {
      parameters {
        threshold = 1.0
        timeframe = "timeframe_1_h"
      }
    }
  }
  filters {
    text        = "error"
    filter_type = "text_or_unspecified"
  }
  incident_settings {
    retriggering_period_seconds = 3600
    notify_on                   = "triggered_only"
  }
  notification_groups {
    notifications {
      integration_id = ibm_logs_outgoing_webhook.goldeneye_slack_integration.id
      notify_on      = "triggered_only"
    }
  }

}
