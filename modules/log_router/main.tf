##############################################################################
# IBM Cloud Log Router v3
##############################################################################

resource "ibm_iam_authorization_policy" "logs_routing_policy" {
  count               = var.skip_logs_routing_auth_policy ? 0 : 1
  source_service_name = "logs-router"
  roles               = ["Sender"]
  description         = "Allow Logs Routing 'Sender' access to the IBM Cloud Logs instance ${var.cloud_logs_instance_crn}."

  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "logs"
  }

  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = regex(".*:(.*)::", var.cloud_logs_instance_crn)[0]
  }
}

resource "time_sleep" "wait_for_auth_policy" {
  depends_on      = [ibm_iam_authorization_policy.logs_routing_policy]
  count           = var.skip_logs_routing_auth_policy ? 0 : 1
  create_duration = "30s"
}

resource "ibm_logs_router_target" "target" {
  depends_on      = [time_sleep.wait_for_auth_policy, ibm_logs_router_settings.settings]
  name            = var.target_name
  destination_crn = var.cloud_logs_instance_crn
}

resource "ibm_logs_router_route" "routes" {
  for_each = { for route in var.routes : route.name => route }

  name       = each.value.name
  managed_by = each.value.managed_by

  dynamic "rules" {
    for_each = each.value.rules
    content {
      action = rules.value.action

      dynamic "targets" {
        for_each = rules.value.targets
        content {
          id = targets.value.id
        }
      }

      dynamic "inclusion_filters" {
        for_each = rules.value.inclusion_filters
        content {
          operand  = inclusion_filters.value.operand
          operator = inclusion_filters.value.operator
          values   = inclusion_filters.value.values
        }
      }
    }
  }
}

resource "ibm_logs_router_settings" "settings" {
  count = var.global_log_routing_settings != null ? 1 : 0

  primary_metadata_region   = var.global_log_routing_settings.primary_metadata_region
  backup_metadata_region    = var.global_log_routing_settings.backup_metadata_region
  permitted_target_regions  = var.global_log_routing_settings.permitted_target_regions
  private_api_endpoint_only = var.global_log_routing_settings.private_api_endpoint_only

  dynamic "default_targets" {
    for_each = var.global_log_routing_settings.default_targets
    content {
      id = default_targets.value
    }
  }
}
