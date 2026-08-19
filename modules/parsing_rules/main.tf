##############################################################################
# Configure Parsing Rules
##############################################################################

resource "ibm_logs_rule_group" "parsing_rule_groups" {
  for_each = {
    for rule_group in var.parsing_rules :
    rule_group.name => rule_group
  }

  instance_id   = var.cloud_logs_instance_id
  region        = var.cloud_logs_region
  endpoint_type = var.cloud_logs_endpoint_type
  name          = each.value.name
  description   = each.value.description
  enabled       = each.value.enabled
  order         = each.value.order

  dynamic "rule_matchers" {
    for_each = each.value.rule_matchers
    content {
      dynamic "application_name" {
        for_each = rule_matchers.value.application_name != null ? [rule_matchers.value.application_name] : []
        content {
          value = application_name.value.value
        }
      }
      dynamic "subsystem_name" {
        for_each = rule_matchers.value.subsystem_name != null ? [rule_matchers.value.subsystem_name] : []
        content {
          value = subsystem_name.value.value
        }
      }
      dynamic "severity" {
        for_each = rule_matchers.value.severity != null ? [rule_matchers.value.severity] : []
        content {
          value = severity.value.value
        }
      }
    }
  }

  dynamic "rule_subgroups" {
    for_each = each.value.rule_subgroups
    content {
      enabled = rule_subgroups.value.enabled
      order   = rule_subgroups.value.order

      dynamic "rules" {
        for_each = rule_subgroups.value.rules
        content {
          name         = rules.value.name
          description  = rules.value.description
          source_field = rules.value.source_field
          enabled      = rules.value.enabled
          order        = rules.value.order

          parameters {
            dynamic "parse_parameters" {
              for_each = rules.value.parameters.parse_parameters != null ? [rules.value.parameters.parse_parameters] : []
              content {
                destination_field = parse_parameters.value.destination_field
                rule              = parse_parameters.value.rule
              }
            }
            dynamic "block_parameters" {
              for_each = rules.value.parameters.block_parameters != null ? [rules.value.parameters.block_parameters] : []
              content {
                keep_blocked_logs = block_parameters.value.keep_blocked_logs
                rule              = block_parameters.value.rule
              }
            }
            dynamic "extract_parameters" {
              for_each = rules.value.parameters.extract_parameters != null ? [rules.value.parameters.extract_parameters] : []
              content {
                rule = extract_parameters.value.rule
              }
            }
            dynamic "json_extract_parameters" {
              for_each = rules.value.parameters.json_extract_parameters != null ? [rules.value.parameters.json_extract_parameters] : []
              content {
                destination_field = json_extract_parameters.value.destination_field
              }
            }
            dynamic "replace_parameters" {
              for_each = rules.value.parameters.replace_parameters != null ? [rules.value.parameters.replace_parameters] : []
              content {
                destination_field = replace_parameters.value.destination_field
                replace_new_val   = replace_parameters.value.replace_new_val
                rule              = replace_parameters.value.rule
              }
            }
            dynamic "allow_parameters" {
              for_each = rules.value.parameters.allow_parameters != null ? [rules.value.parameters.allow_parameters] : []
              content {
                keep_blocked_logs = allow_parameters.value.keep_blocked_logs
                rule              = allow_parameters.value.rule
              }
            }
            dynamic "extract_timestamp_parameters" {
              for_each = rules.value.parameters.extract_timestamp_parameters != null ? [rules.value.parameters.extract_timestamp_parameters] : []
              content {
                format   = extract_timestamp_parameters.value.format
                standard = extract_timestamp_parameters.value.standard
              }
            }
            dynamic "remove_fields_parameters" {
              for_each = rules.value.parameters.remove_fields_parameters != null ? [rules.value.parameters.remove_fields_parameters] : []
              content {
                fields = remove_fields_parameters.value.fields
              }
            }
            dynamic "json_stringify_parameters" {
              for_each = rules.value.parameters.json_stringify_parameters != null ? [rules.value.parameters.json_stringify_parameters] : []
              content {
                destination_field = json_stringify_parameters.value.destination_field
                delete_source     = json_stringify_parameters.value.delete_source
              }
            }
            dynamic "json_parse_parameters" {
              for_each = rules.value.parameters.json_parse_parameters != null ? [rules.value.parameters.json_parse_parameters] : []
              content {
                destination_field = json_parse_parameters.value.destination_field
                delete_source     = json_parse_parameters.value.delete_source
                override_dest     = json_parse_parameters.value.override_dest
              }
            }
          }
        }
      }
    }
  }
}
