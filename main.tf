locals {
  instance_name = var.instance_name != null ? var.instance_name : "cloud-logs-${var.region}"
}


# Cloud Logs
resource "ibm_resource_instance" "cloud_logs" {
  depends_on        = [time_sleep.wait_for_cos_authorization_policy]
  name              = local.instance_name
  resource_group_id = var.resource_group_id
  service           = "logs"
  plan              = var.plan
  tags              = var.resource_tags
  location          = var.region
  parameters = {
    "logs_bucket_crn"         = var.data_storage.logs_data.enabled ? var.data_storage.logs_data.bucket_crn : null
    "logs_bucket_endpoint"    = var.data_storage.logs_data.enabled ? var.data_storage.logs_data.bucket_endpoint : null
    "metrics_bucket_crn"      = var.data_storage.metrics_data.enabled ? var.data_storage.metrics_data.bucket_crn : null
    "metrics_bucket_endpoint" = var.data_storage.metrics_data.enabled ? var.data_storage.metrics_data.bucket_endpoint : null
    "retention_period"        = var.retention_period
  }
  service_endpoints = var.service_endpoints
}

resource "ibm_resource_tag" "cloud_logs_tag" {
  count       = length(var.access_tags) == 0 ? 0 : 1
  resource_id = ibm_resource_instance.cloud_logs.crn
  tags        = var.access_tags
  tag_type    = "access"
}

# If logs or metrics data is enabled, parse details from it
module "cos_bucket_crn_parser" {
  for_each = { for index, bucket in var.data_storage : index => bucket if bucket.enabled && !bucket.skip_cos_auth_policy }
  source   = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version  = "1.2.0"
  crn      = each.value.bucket_crn
}

resource "ibm_iam_authorization_policy" "cos_policy" {
  for_each                 = { for index, bucket in var.data_storage : index => bucket if bucket.enabled && !bucket.skip_cos_auth_policy }
  source_service_name      = "logs"
  source_resource_group_id = var.resource_group_id
  roles                    = ["Writer"]
  description              = "Allow Cloud logs instances `Writer` access to the COS bucket with ID ${regex("bucket:(.*)", each.value.bucket_crn)[0]}, in the COS instance with ID ${regex(".*:(.*):bucket:.*", each.value.bucket_crn)[0]}."

  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "cloud-object-storage"
  }

  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = module.cos_bucket_crn_parser[each.key].account_id
  }

  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = regex(".*:(.*):bucket:.*", each.value.bucket_crn)[0]
  }

  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "bucket"
  }

  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = regex("bucket:(.*)", each.value.bucket_crn)[0]
  }
}

resource "time_sleep" "wait_for_cos_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.cos_policy]
  # trigger once if any of the buckets create an auth policy
  count           = anytrue([for _, bucket in var.data_storage : bucket.enabled && !bucket.skip_cos_auth_policy]) ? 1 : 0
  create_duration = "30s"
}

##############################################################################
# EN Integration
##############################################################################

module "en_integration" {
  count                                  = length(var.existing_event_notifications_instances) > 0 ? 1 : 0
  source                                 = "./modules/webhook"
  cloud_logs_instance_id                 = ibm_resource_instance.cloud_logs.guid
  cloud_logs_instance_name               = local.instance_name
  cloud_logs_region                      = var.region
  existing_event_notifications_instances = var.existing_event_notifications_instances
}

##############################################################################
# Logs Routing
##############################################################################

# Create required auth policy to allow log routing service to send logs to the cloud logs instance
resource "ibm_iam_authorization_policy" "logs_routing_policy" {
  count               = !var.skip_logs_routing_auth_policy ? 1 : 0
  source_service_name = "logs-router"
  roles               = ["Sender"]
  description         = "Allow Logs Routing `Sender` access to the IBM Cloud Logs with ID ${ibm_resource_instance.cloud_logs.guid}."

  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "logs"
  }

  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = ibm_resource_instance.cloud_logs.account_id
  }

  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = ibm_resource_instance.cloud_logs.guid
  }
}

resource "random_string" "random_tenant_suffix" {
  length  = 4
  numeric = true
  upper   = false
  lower   = false
  special = false
}

locals {
  logs_routing_tenant_target_name = replace(substr(local.instance_name, 0, 32), "/[^a-zA-Z0-9]+$/", "")
}

resource "ibm_logs_router_tenant" "logs_router_tenant_instances" {
  for_each = toset(var.logs_routing_tenant_regions)
  name     = "${each.key}-${random_string.random_tenant_suffix.result}"
  region   = each.key
  targets {
    log_sink_crn = ibm_resource_instance.cloud_logs.crn
    name         = local.logs_routing_tenant_target_name
    parameters {
      host = ibm_resource_instance.cloud_logs.extensions.external_ingress
      port = 443
    }
  }
}

##############################################################################
# Configure Logs Policies - TCO Optimizer
##############################################################################

module "logs_policies" {
  count                        = length(var.policies) > 0 ? 1 : 0
  source                       = "./modules/logs_policy"
  cloud_logs_instance_id       = ibm_resource_instance.cloud_logs.guid
  cloud_logs_region            = ibm_resource_instance.cloud_logs.location
  cloud_logs_service_endpoints = ibm_resource_instance.cloud_logs.service_endpoints
  policies                     = var.policies
}

##############################################################################
# CBR
##############################################################################

locals {
  default_operations = [{
    api_types = [
      {
        "api_type_id" : "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
      }
    ]
  }]
}

module "cbr_rule" {
  count            = length(var.cbr_rules)
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.32.4"
  rule_description = var.cbr_rules[count.index].description
  enforcement_mode = var.cbr_rules[count.index].enforcement_mode
  rule_contexts    = var.cbr_rules[count.index].rule_contexts
  resources = [{
    attributes = [
      {
        name  = "accountId"
        value = var.cbr_rules[count.index].account_id
      },
      {
        name  = "serviceName"
        value = "logs"
      },
      {
        name     = "serviceInstance"
        value    = ibm_resource_instance.cloud_logs.guid
        operator = "stringEquals"
      }
    ]
  }]
  operations = var.cbr_rules[count.index].operations == null ? local.default_operations : var.cbr_rules[count.index].operations
}
