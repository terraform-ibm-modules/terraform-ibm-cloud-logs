# IBM Cloud Logs module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-cloud-logs?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-cloud-logs/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

This module supports configuring an IBM Cloud Logs instance, log routing tenants to enable platform logs and cloud logs policies.

## Usage

To provision Cloud Logs instance

```hcl
# Locals
locals {
  region      = "us-south"
  default_operations = [{
    api_types = [
      {
        "api_type_id" : "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
      }
    ]
  }]
}

# Required providers
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "X.Y.Z" # lock into a supported provider version
    }
  }
}
provider "ibm" {
  ibmcloud_api_key = XXXXXXXXXXXX  # pragma: allowlist secret
  region           = local.region
}

# IBM Cloud Logs
module "cloud_logs" {
  source            = "terraform-ibm-modules/cloud-logs/ibm"
  version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  region            = local.region
  data_storage = {
    # logs and metrics buckets must be different
    logs_data = {
      enabled         = true
      bucket_crn      = "crn:v1:bluemix:public:cloud-object-storage:global:a/......"
      bucket_endpoint = "s3.direct.us-south.cloud-object-storage.appdomain.cloud"
    },
    metrics_data = {
      enabled         = true
      bucket_crn      = "crn:v1:bluemix:public:cloud-object-storage:global:a/......"
      bucket_endpoint = "s3.direct.us-south.cloud-object-storage.appdomain.cloud"
    }
  }

  # Create policies
  policies = [{
    logs_policy_name        = "logs_policy_name"
    logs_policy_priority    = "type_medium"
    application_rule = [{
      name         = "test-system-app"
      rule_type_id = "start_with"
    }]
    subsystem_rule = [{
      name         = "test-sub-system"
      rule_type_id = "start_with"
    }]
    log_rules = [{
      severities = ["info", "debug"]
    }]
  }]

  # CBR
  cbr_rules = [{
    description      = "Rules for cloud logs access"
    account_id       = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
    enforcement_mode = "report"
    rule_contexts = [{
      attributes = [
        {
          "name" : "endpointType",
          "value" : "private"
        },
        {
          name  = "networkZoneId"
          value = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
        }
      ]
      }]
      operations = local.default_operations
  }]
}
```

### Required IAM access policies

You need the following permissions to run this module.

- Service
  - **Resource group only**
    - `Viewer` access on the specific resource group
  - **Cloud Logs**
    - `Editor` platform access
    - `Manager` service access
  - **IBM Cloud Logs Routing** (Required if creating tenants, which are required to enable platform logs)
    - `Editor` platform access
    - `Manager` service access
  - **Tagging service** (Required if attaching access tags to the ICL instance)
    - `Editor` platform access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.80.2, < 2.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1, < 4.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.32.4 |
| <a name="module_cos_bucket_crn_parser"></a> [cos\_bucket\_crn\_parser](#module\_cos\_bucket\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.2.0 |
| <a name="module_en_integration"></a> [en\_integration](#module\_en\_integration) | ./modules/webhook | n/a |
| <a name="module_logs_policies"></a> [logs\_policies](#module\_logs\_policies) | ./modules/logs_policy | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.cos_policy](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.logs_routing_policy](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_logs_router_tenant.logs_router_tenant_instances](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/logs_router_tenant) | resource |
| [ibm_resource_instance.cloud_logs](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_tag.cloud_logs_tag](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_tag) | resource |
| [random_string.random_tenant_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait_for_cos_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the IBM Cloud Logs instance created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial. | `list(string)` | `[]` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | (Optional, list) List of context-based restrictions rules to create | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>    operations = optional(list(object({<br/>      api_types = list(object({<br/>        api_type_id = string<br/>      }))<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_data_storage"></a> [data\_storage](#input\_data\_storage) | A logs data bucket and a metrics bucket in IBM Cloud Object Storage to store your IBM Cloud Logs data for long term storage, search, analysis and alerting. | <pre>object({<br/>    logs_data = optional(object({<br/>      enabled              = optional(bool, false)<br/>      bucket_crn           = optional(string)<br/>      bucket_endpoint      = optional(string)<br/>      skip_cos_auth_policy = optional(bool, false)<br/>    }), {})<br/>    metrics_data = optional(object({<br/>      enabled              = optional(bool, false)<br/>      bucket_crn           = optional(string)<br/>      bucket_endpoint      = optional(string)<br/>      skip_cos_auth_policy = optional(bool, false)<br/>    }), {})<br/>    }<br/>  )</pre> | <pre>{<br/>  "logs_data": null,<br/>  "metrics_data": null<br/>}</pre> | no |
| <a name="input_existing_event_notifications_instances"></a> [existing\_event\_notifications\_instances](#input\_existing\_event\_notifications\_instances) | List of Event Notifications instance details for routing critical events that occur in your IBM Cloud Logs. | <pre>list(object({<br/>    crn                  = string<br/>    integration_name     = optional(string)<br/>    skip_iam_auth_policy = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | The name of the IBM Cloud Logs instance to create. Defaults to 'cloud-logs-<region>' | `string` | `null` | no |
| <a name="input_logs_routing_tenant_regions"></a> [logs\_routing\_tenant\_regions](#input\_logs\_routing\_tenant\_regions) | Pass a list of regions to create a tenant for that is targetted to the IBM Cloud Logs instance created by this module. To manage platform logs that are generated by IBM Cloud® services in a region of IBM Cloud, you must create a tenant in each region that you operate. Leave the list empty if you don't want to create any tenants. NOTE: You can only have 1 tenant per region in an account. | `list(any)` | `[]` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | The IBM Cloud Logs plan to provision. Available: standard | `string` | `"standard"` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | Configuration of IBM Cloud Logs policies. | <pre>list(object({<br/>    logs_policy_name        = string<br/>    logs_policy_description = optional(string, null)<br/>    logs_policy_priority    = string<br/>    application_rule = optional(list(object({<br/>      name         = string<br/>      rule_type_id = string<br/>    })))<br/>    subsystem_rule = optional(list(object({<br/>      name         = string<br/>      rule_type_id = string<br/>    })))<br/>    log_rules = optional(list(object({<br/>      severities = list(string)<br/>    })))<br/>    archive_retention = optional(list(object({<br/>      id = string<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The IBM Cloud region where IBM Cloud logs instance will be created. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The id of the IBM Cloud resource group where the instance will be created. | `string` | `null` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Tags associated with the IBM Cloud Logs instance (Optional, array of strings). | `list(string)` | `[]` | no |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period) | The number of days IBM Cloud Logs will retain the logs data in Priority insights. Allowed values: 7, 14, 30, 60, 90. | `number` | `7` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The type of the service endpoint that will be set for the IBM Cloud Logs instance. Allowed values: public-and-private. | `string` | `"public-and-private"` | no |
| <a name="input_skip_logs_routing_auth_policy"></a> [skip\_logs\_routing\_auth\_policy](#input\_skip\_logs\_routing\_auth\_policy) | Whether to create an IAM authorization policy that permits the Logs Routing server 'Sender' access to the IBM Cloud Logs instance created by this module. | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The account id where IBM Cloud logs instance is provisioned. |
| <a name="output_crn"></a> [crn](#output\_crn) | The CRN of the provisioned IBM Cloud Logs instance. |
| <a name="output_guid"></a> [guid](#output\_guid) | The guid of the provisioned IBM Cloud Logs instance. |
| <a name="output_ingress_endpoint"></a> [ingress\_endpoint](#output\_ingress\_endpoint) | The public ingress endpoint of the provisioned IBM Cloud Logs instance. |
| <a name="output_ingress_private_endpoint"></a> [ingress\_private\_endpoint](#output\_ingress\_private\_endpoint) | The private ingress endpoint of the provisioned IBM Cloud Logs instance. |
| <a name="output_logs_policies_details"></a> [logs\_policies\_details](#output\_logs\_policies\_details) | The details of the IBM Cloud logs policies created. |
| <a name="output_name"></a> [name](#output\_name) | The name of the provisioned IBM Cloud Logs instance. |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The resource group where IBM Cloud Logs instance resides. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
