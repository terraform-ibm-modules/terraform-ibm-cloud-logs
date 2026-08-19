# IBM Cloud Logs Parsing Rules

The module supports configuring IBM Cloud Logs parsing rule groups. Parsing rules allow you to transform, extract, block, or reformat log data as it is ingested into your IBM Cloud Logs instance.

For more information visit [here](https://cloud.ibm.com/docs/cloud-logs?topic=cloud-logs-rules_groups).

## Usage

```hcl
module "parsing_rules" {
  source                       = "terraform-ibm-modules/cloud-logs/ibm//modules/parsing_rules"
  version                      = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  cloud_logs_instance_id       = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  cloud_logs_region            = "us-south"
  cloud_logs_endpoint_type = "public"
  parsing_rules = [{
    name        = "mysql-parse"
    description = "Parse MySQL audit log fields"
    enabled     = true
    order       = 1
    rule_matchers = [{
      subsystem_name = {
        value = "mysql"
      }
    }]
    rule_subgroups = [{
      enabled = true
      order   = 1
      rules = [{
        name         = "mysql-parse"
        source_field = "text"
        enabled      = true
        order        = 1
        parameters = {
          parse_parameters = {
            destination_field = "text"
            rule              = "(?P<timestamp>[^,]+),(?P<hostname>[^,]+),(?P<username>[^,]+),(?P<ip>[^,]+),(?P<connectionId>[0-9]+),(?P<queryId>[0-9]+),(?P<operation>[^,]+),(?P<database>[^,]+),'?(?P<object>.*)'?,(?P<returnCode>[0-9]+)"
          }
        }
      }]
    }]
  }]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.80.2, < 3.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_logs_rule_group.parsing_rule_groups](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/logs_rule_group) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_logs_endpoint_type"></a> [cloud\_logs\_endpoint\_type](#input\_cloud\_logs\_endpoint\_type) | The endpoint type to use to communicate with the existing IBM Cloud Logs instance. Allowed values: public, private. | `string` | n/a | yes |
| <a name="input_cloud_logs_instance_id"></a> [cloud\_logs\_instance\_id](#input\_cloud\_logs\_instance\_id) | The GUID of the existing IBM Cloud Logs instance. | `string` | n/a | yes |
| <a name="input_cloud_logs_region"></a> [cloud\_logs\_region](#input\_cloud\_logs\_region) | The IBM Cloud region where the existing IBM Cloud Logs instance is located. | `string` | n/a | yes |
| <a name="input_parsing_rules"></a> [parsing\_rules](#input\_parsing\_rules) | Configuration of IBM Cloud Logs parsing rule groups. | <pre>list(object({<br/>    name        = string<br/>    description = optional(string, null)<br/>    enabled     = optional(bool, true)<br/>    order       = optional(number, null)<br/>    rule_matchers = optional(list(object({<br/>      application_name = optional(object({<br/>        value = string<br/>      }), null)<br/>      subsystem_name = optional(object({<br/>        value = string<br/>      }), null)<br/>      severity = optional(object({<br/>        value = string<br/>      }), null)<br/>    })), [])<br/>    rule_subgroups = list(object({<br/>      enabled = optional(bool, true)<br/>      order   = optional(number, null)<br/>      rules = list(object({<br/>        name         = string<br/>        description  = optional(string, null)<br/>        source_field = string<br/>        enabled      = optional(bool, true)<br/>        order        = optional(number, null)<br/>        parameters = object({<br/>          parse_parameters = optional(object({<br/>            destination_field = string<br/>            rule              = string<br/>          }), null)<br/>          block_parameters = optional(object({<br/>            keep_blocked_logs = bool<br/>            rule              = string<br/>          }), null)<br/>          extract_parameters = optional(object({<br/>            rule = string<br/>          }), null)<br/>          json_extract_parameters = optional(object({<br/>            destination_field = string<br/>          }), null)<br/>          replace_parameters = optional(object({<br/>            destination_field = string<br/>            replace_new_val   = string<br/>            rule              = string<br/>          }), null)<br/>          allow_parameters = optional(object({<br/>            keep_blocked_logs = bool<br/>            rule              = string<br/>          }), null)<br/>          extract_timestamp_parameters = optional(object({<br/>            format   = string<br/>            standard = string<br/>          }), null)<br/>          remove_fields_parameters = optional(object({<br/>            fields = list(string)<br/>          }), null)<br/>          json_stringify_parameters = optional(object({<br/>            destination_field = optional(string, null)<br/>            delete_source     = optional(bool, null)<br/>          }), null)<br/>          json_parse_parameters = optional(object({<br/>            destination_field = optional(string, null)<br/>            delete_source     = optional(bool, null)<br/>            override_dest     = optional(bool, null)<br/>          }), null)<br/>        })<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_parsing_rule_groups_details"></a> [parsing\_rule\_groups\_details](#output\_parsing\_rule\_groups\_details) | The details of the IBM Cloud Logs parsing rule groups created. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
