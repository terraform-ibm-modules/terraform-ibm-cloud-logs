# Configuring complex inputs for Cloud Automation for Cloud Logs

Several optional input variables in the IBM Cloud [Cloud Logs instances deployable architecture](https://cloud.ibm.com/catalog#deployable_architecture) use complex object types. You specify these inputs when you configure deployable architecture.

* Existing Event Notification Instances (`existing_event_notifications_instances`)
* Cloud Logs policies (`cloud_logs_policies`)
* Cloud Logs data bucket retention policy(`cloud_log_data_bucket_retention_policy`)

## Existing Event Notification Instances <a name="existing_event_notifications_instances"></a>

The `existing_event_notifications_instances` input variable allows you to provide a list of existing Event Notification (EN) instances that will be integrated with the Cloud Logging service. For each EN instance, you need to specify its CRN (Cloud Resource Name) and region. You can optionally configure a integration name and control whether to skip the creation of an authentication policy for the instance.

* Variable name: `existing_event_notifications_instances`.
* Type: A list of objects. Each object represents an EN instance.
* Default value: An empty list (`[]`).

### Options for existing_event_notifications_instances

* `crn` (required): The Cloud Resource Name (CRN) of the Event Notification instance.

* `integration_name` (optional): The name of the Event Notification integration that gets created. Defaults to `"cloud-logs-en-integration"`.

* `skip_iam_auth_policy` (optional): A boolean flag to determine whether to skip the creation of an authentication policy that allows Cloud Logs 'Event Source Manager' role access in the existing event notification instance. Defaults to `false`.

* `integration_endpoint_type` (optional): The endpoint type of the Event Notification integration. Allowed values: `private` and `default_or_public`. Defaults to `private`.

* `cloud_logs_endpoint_type` (optional): The Cloud Logs endpoint Terraform uses for the API call that creates the Event Notifications integration. Allowed values: `private` and `public`. Defaults to `private`.

### Example Existing Event Notification Instance Configuration

```hcl
[
  {
    crn                       = "crn:v1:bluemix:public:...:event-notifications:instance"
    integration_name          = "custom-logging-en-integration"
    skip_iam_auth_policy      = true
    cloud_logs_endpoint_type  = "public"
    integration_endpoint_type = "default_or_public"
  },
  {
    crn                       = "crn:v1:bluemix:public:...:event-notifications:instance"
    skip_iam_auth_policy      = false
    cloud_logs_endpoint_type  = "private"
    integration_endpoint_type = "private"
  }
]
```

In this example:

* The first EN instance has a integration name `"custom-logging-en-integration"` skips the authentication policy.
* The second EN instance uses the default integration name and includes the authentication policy.

## Cloud Logs Policies <a name="cloud_logs_policies"></a>

The `cloud_logs_policies` input variable allows you to provide a list of policies that will be configured in the Cloud Logs service. Refer [here](https://cloud.ibm.com/docs/cloud-logs?topic=cloud-logs-tco-optimizer) for more information.

* Variable name: `cloud_logs_policies`.
* Type: A list of objects. Each object represents a policy.
* Default value: An empty list (`[]`).

### Options for cloud_logs_policies

* `logs_policy_name` (required): The unique policy name.
* `logs_policy_description` (optional): The description of the policy to create.
* `logs_policy_priority` (required): The priority to determine the pipeline for the logs. Allowed values are: type_unspecified, type_block, type_low, type_medium, type_high. High (priority value) sent to 'Priority insights' (TCO pipeline), Medium to 'Analyze and alert', Low to 'Store and search', Blocked are not sent to any pipeline.
* `application_rule` (optional): The rules to include in the policy configuration for matching applications.
* `subsystem_rule` (optional): The subsystem rules to include in the policy configuration for matching applications.
* `log_rules` (required): The log severities to include in the policy configuration.
* `archive_retention` (optional): Define archive retention.

### Example cloud_logs_policies

```hcl
[
  {
    logs_policy_name     = "logs-policy-1"
    logs_policy_description = "Send info and debug logs of the application (name starts with `test-system-app`) and the subsystem (name starts with `test-sub-system`) logs to Store nad search pipeline"
    logs_policy_priority = "type_low"
    application_rule = [{
      name         = "test-system-app"
      rule_type_id = "start_with"
    }]
    log_rules = [{
      severities = ["info", "debug"]
    }]
    subsystem_rule = [{
      name         = "test-sub-system"
      rule_type_id = "start_with"
    }]
  },
  {
    logs_policy_name     = "logs-policy-2"
    logs_policy_description = "Send error logs of all applications and all subsystems to Analyze and Alert pipeline"
    logs_policy_priority = "type_medium"
    log_rules = [{
      severities = ["error"]
    }]
  }
]
```

## cloud_log_data_bucket_retention_policy <a name="cloud_log_data_bucket_retention_policy"></a>

The `cloud_log_data_bucket_retention_policy` input variable allows you to provide the retention policy of the IBM Cloud Logs data bucket that will be configured. Refer [here](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-immutable) for more information.

* Variable name: `cloud_log_data_bucket_retention_policy`.
* Type: An object representing a retention policy.
* Default value: null (`null`).

### Options for cloud_log_data_bucket_retention_policy

* `default` (optional): The number of days that an object can remain unmodified in an Object Storage bucket.
* `maximum` (optional): The maximum number of days that an object can be kept unmodified in the bucket.
* `minimum` (optional): The minimum number of days that an object must be kept unmodified in the bucket.
* `permanent` (optional): Whether permanent retention status is enabled for the Object Storage bucket.

### Example cloud_log_data_bucket_retention_policy

```hcl
{
    default   = 90
    maximum   = 350
    minimum   = 90
    permanent = false
}
```

## Cloud Logs Parsing Rules <a name="logs_parsing_rules"></a>

The `logs_parsing_rules` input variable allows you to provide a list of parsing rule groups that will be configured in the Cloud Logs instance. Parsing rules let you extract, parse, block, or otherwise transform log records before they are stored. Refer [here](https://cloud.ibm.com/docs/cloud-logs?topic=cloud-logs-rules_groups) for more information.

* Variable name: `logs_parsing_rules`.
* Type: A list of objects. Each object represents a rule group (`ibm_logs_rule_group`).
* Default value: An empty list (`[]`).

### Options for logs_parsing_rules

* `name` (required): The unique name of the rule group.
* `description` (optional): A description of the rule group.
* `enabled` (optional): Whether the rule group is enabled. Defaults to `true`.
* `order` (optional): The priority order of the rule group. Lower values are evaluated first.
* `rule_matchers` (optional): A list of matchers that determine which logs this rule group applies to. Each matcher may specify one of:
  * `application_name`: Match by application name (`value`).
  * `subsystem_name`: Match by subsystem name (`value`).
  * `severity`: Match by severity level (`value`).
* `rule_subgroups` (required): A list of rule subgroups, each containing:
  * `enabled` (optional): Whether the subgroup is enabled. Defaults to `true`.
  * `order` (optional): The priority order of the subgroup.
  * `rules` (required): A list of rules in the subgroup. Each rule has:
    * `name` (required): The name of the rule.
    * `description` (optional): A description of the rule.
    * `source_field` (required): The log field this rule is applied to (e.g. `"text"`).
    * `enabled` (optional): Whether the rule is enabled. Defaults to `true`.
    * `order` (optional): The priority order of the rule.
    * `parameters` (required): Exactly one parameter block describing the rule type:
      * `parse_parameters`: Extract named capture groups from a log field using a regex.
      * `block_parameters`: Block logs matching a regex.
      * `extract_parameters`: Extract a value from a log field using a regex.
      * `json_extract_parameters`: Extract a value from a JSON log field.
      * `replace_parameters`: Replace a value in a log field using a regex.
      * `allow_parameters`: Allow only logs matching a regex.
      * `extract_timestamp_parameters`: Extract a timestamp from a log field.
      * `remove_fields_parameters`: Remove fields from a log record.
      * `json_stringify_parameters`: Stringify a JSON log field.
      * `json_parse_parameters`: Parse a stringified JSON value in a log field.

### Example logs_parsing_rules

```hcl
[
  {
    name        = "mysql-parse"
    description = "Parse MySQL audit log fields"
    enabled     = true
    order       = 4294967
    rule_matchers = [
      {
        subsystem_name = {
          value = "mysql"
        }
      }
    ]
    rule_subgroups = [
      {
        enabled = true
        order   = 1
        rules = [
          {
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
          }
        ]
      }
    ]
  }
]
```

## Configuring Context-Based Restrictions (CBRs) <a name="cloud_logs_cbr_rules"></a>

The `cloud_logs_cbr_rules` input variable allows you to provide a rule for the target service to enforce access restrictions for the service based on the context of access requests. Contexts are criteria that include the network location of access requests, the endpoint type from where the request is sent, etc.

* Variable name: `cloud_logs_cbr_rules`.
* Type: A list of objects. Allows only one object representing a rule for the target service
* Default value: An empty list (`[]`).

### Options for cloud_logs_cbr_rules

* `description` (required): The description of the rule to create.
* `account_id` (required): The IBM Cloud Account ID
* `rule_contexts` (required): (List) The contexts the rule applies to
  * `attributes` (optional): (List) Individual context attributes
    * `name` (required): The attribute name.
    * `value`(required): The attribute value.

* `enforcement_mode` (required): The rule enforcement mode can have the following values:
  * `enabled` - The restrictions are enforced and reported. This is the default.
  * `disabled` - The restrictions are disabled. Nothing is enforced or reported.
  * `report` - The restrictions are evaluated and reported, but not enforced.
* `operations` (optional): The operations this rule applies to
  * `api_types`(required): (List) The API types this rule applies to.
    * `api_type_id`(required): The API type ID

### Example Rule For Context-Based Restrictions Configuration

```hcl
[
  {
    "description"     : "Cloud Logs Instance can be accessed from xyz"
    "account_id"      : "defc0df06b644a9cabc6e44f55b3880s."
    "rule_contexts"   : [{
      "attributes"  : [
        {
          "name" : "endpointType",
          "value" : "private"
        },
        {
          "name"  : "networkZoneId"
          "value" : "93a51a1debe2674193217209601dde6f" # pragma: allowlist secret
        }
      ]
    }]
    "enforcement_mode" : "enabled"
    "operations" : [{
      "api_types" : [{
        "api_type_id" : "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
      }]
    }]
  }
]
```
