##############################################################################
# Configure Logs Policies - TCO Optimizer
##############################################################################

resource "ibm_logs_policy" "logs_policies" {
  for_each = {
    for policy in var.policies :
    policy.logs_policy_name => policy
  }
  instance_id   = var.cloud_logs_instance_id
  region        = var.cloud_logs_region
  endpoint_type = var.cloud_logs_service_endpoints
  name          = each.value.logs_policy_name
  description   = each.value.logs_policy_description
  priority      = each.value.logs_policy_priority

  dynamic "application_rule" {
    for_each = each.value.application_rule != null ? each.value.application_rule : []
    content {
      name         = application_rule.value["name"]
      rule_type_id = application_rule.value["rule_type_id"]
    }
  }

  dynamic "log_rules" {
    for_each = each.value.log_rules
    content {
      severities = log_rules.value["severities"]
    }
  }

  dynamic "subsystem_rule" {
    for_each = each.value.subsystem_rule != null ? each.value.subsystem_rule : []
    content {
      name         = subsystem_rule.value["name"]
      rule_type_id = subsystem_rule.value["rule_type_id"]
    }
  }

  dynamic "archive_retention" {
    for_each = each.value.archive_retention != null ? each.value.archive_retention : []
    content {
      id = archive_retention.value["id"]
    }
  }
}
