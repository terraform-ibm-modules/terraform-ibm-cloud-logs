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
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.76.1, < 2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_logs_policy.logs_policies](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/logs_policy) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_logs_instance_id"></a> [cloud\_logs\_instance\_id](#input\_cloud\_logs\_instance\_id) | The guid of the cloud logs instance. | `string` | n/a | yes |
| <a name="input_cloud_logs_region"></a> [cloud\_logs\_region](#input\_cloud\_logs\_region) | The region of cloud logs instance. | `string` | n/a | yes |
| <a name="input_cloud_logs_service_endpoints"></a> [cloud\_logs\_service\_endpoints](#input\_cloud\_logs\_service\_endpoints) | The type of the service endpoint that will be set for the IBM Cloud Logs instance. Allowed values: public-and-private. | `string` | n/a | yes |
| <a name="input_policies"></a> [policies](#input\_policies) | Configuration of Cloud Logs policies. | <pre>list(object({<br>    logs_policy_name        = string<br>    logs_policy_description = optional(string, null)<br>    logs_policy_priority    = string<br>    application_rule = optional(list(object({<br>      name         = string<br>      rule_type_id = string<br>    })))<br>    subsystem_rule = optional(list(object({<br>      name         = string<br>      rule_type_id = string<br>    })))<br>    log_rules = optional(list(object({<br>      severities = list(string)<br>    })))<br>    archive_retention = optional(list(object({<br>      id = string<br>    })))<br>  }))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_logs_policies_details"></a> [logs\_policies\_details](#output\_logs\_policies\_details) | The details of the Cloud logs policies created. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
