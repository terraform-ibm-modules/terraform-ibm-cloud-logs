# Configuring Event Notifications Webhook

To send events that are generated when an alert is triggered in an IBM Cloud Logs instance, you must connect your IBM Cloud Logs instance to Event Notifications by configuring an outbound integration.

 For more information visit [here](https://cloud.ibm.com/docs/cloud-logs?topic=cloud-logs-event-notifications-configure).

## Usage

```hcl
module "en_integration" {
  source            = "terraform-ibm-modules/cloud-logs/ibm//modules/webhook"
  version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  cloud_logs_instance_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  cloud_logs_region = "us-south"
  existing_event_notifications_instances = [{
    en_instance_id      = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
    en_region           = "us-south"
    en_integration_name = "en-integration-1"
    }
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.80.2, < 2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.en_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_logs_outgoing_webhook.en_integration](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/logs_outgoing_webhook) | resource |
| [time_sleep.wait_for_en_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_logs_instance_id"></a> [cloud\_logs\_instance\_id](#input\_cloud\_logs\_instance\_id) | The GUID of the existing IBM Cloud Logs instance. | `string` | n/a | yes |
| <a name="input_cloud_logs_instance_name"></a> [cloud\_logs\_instance\_name](#input\_cloud\_logs\_instance\_name) | The name of the existing IBM Cloud Logs instance. It is used as a prefix for the outgoing webhook name if the existing\_event\_notification\_instances does not set en\_integration\_name. | `string` | n/a | yes |
| <a name="input_cloud_logs_region"></a> [cloud\_logs\_region](#input\_cloud\_logs\_region) | The IBM Cloud region where the existing Cloud Logs instance is located. | `string` | n/a | yes |
| <a name="input_existing_event_notifications_instances"></a> [existing\_event\_notifications\_instances](#input\_existing\_event\_notifications\_instances) | List of Event Notifications instance details for routing critical events that occur in your IBM Cloud Logs. | <pre>list(object({<br/>    crn                       = string<br/>    integration_name          = optional(string)<br/>    integration_endpoint_type = optional(string, "default_or_public") # https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6673<br/>    skip_iam_auth_policy      = optional(bool, false)<br/>    cloud_logs_endpoint_type  = optional(string, "public")<br/>  }))</pre> | n/a | yes |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
