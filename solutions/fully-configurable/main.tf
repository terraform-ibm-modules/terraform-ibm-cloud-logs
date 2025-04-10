#######################################################################################################################
# Resource Group
#######################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  existing_resource_group_name = var.existing_resource_group_name
}

#######################################################################################################################
# Cloud Logs
#######################################################################################################################

locals {
  prefix            = var.prefix != null ? (var.prefix != "" ? var.prefix : null) : null
  create_cloud_logs = var.existing_cloud_logs_crn == null
  cloud_logs_crn    = local.create_cloud_logs ? module.cloud_logs[0].crn : var.existing_cloud_logs_crn
}

module "cloud_logs" {
  count                                  = local.create_cloud_logs ? 1 : 0
  source                                 = "../.."
  resource_group_id                      = module.resource_group.resource_group_id
  region                                 = var.region
  instance_name                          = var.cloud_logs_instance_name
  plan                                   = "standard" # not a variable because there is only one option
  resource_tags                          = var.cloud_logs_resource_tags
  access_tags                            = var.cloud_logs_access_tags
  retention_period                       = var.cloud_logs_retention_period
  service_endpoints                      = "public-and-private" # not a variable because there is only one option
  existing_event_notifications_instances = var.existing_event_notifications_instances
  data_storage = {
    logs_data = {
      enabled         = true
      bucket_crn      = module.buckets.buckets[local.logs_bucket_name].bucket_crn
      bucket_endpoint = module.buckets.buckets[local.logs_bucket_name].s3_endpoint_direct
    },
    metrics_data = {
      enabled         = true
      bucket_crn      = module.buckets.buckets[local.metrics_bucket_name].bucket_crn
      bucket_endpoint = module.buckets.buckets[local.metrics_bucket_name].s3_endpoint_direct
    }
  }
  logs_routing_tenant_regions   = var.logs_routing_tenant_regions
  skip_logs_routing_auth_policy = var.skip_logs_routing_auth_policy
  policies                      = var.logs_policies
}

#######################################################################################################################
# COS
#######################################################################################################################

locals {
  use_kms_module    = var.kms_encryption_enabled_bucket && var.existing_kms_key_crn == null
  kms_region        = var.kms_encryption_enabled_bucket ? module.existing_kms_crn_parser[0].region : null
  existing_kms_guid = var.kms_encryption_enabled_bucket ? module.existing_kms_crn_parser[0].service_instance : var.existing_kms_key_crn != null ? module.existing_kms_key_crn_parser[0].service_instance : null
  kms_service_name  = var.kms_encryption_enabled_bucket ? module.existing_kms_crn_parser[0].service_name : var.existing_kms_key_crn != null ? module.existing_kms_key_crn_parser[0].service_name : null
  kms_account_id    = var.kms_encryption_enabled_bucket ? module.existing_kms_crn_parser[0].account_id : var.existing_kms_key_crn != null ? module.existing_kms_key_crn_parser[0].account_id : null

  logs_bucket_name    = try("${local.prefix}-${var.logs_cos_bucket_name}", var.logs_cos_bucket_name)
  metrics_bucket_name = try("${local.prefix}-${var.metrics_cos_bucket_name}", var.metrics_cos_bucket_name)
  cos_instance_guid   = module.existing_cos_instance_crn_parser.service_instance

  key_ring_name = try("${local.prefix}-${var.cloud_logs_cos_key_ring_name}", var.cloud_logs_cos_key_ring_name)
  key_name      = try("${local.prefix}-${var.cloud_logs_cos_key_name}", var.cloud_logs_cos_key_name)
  kms_key_crn   = var.kms_encryption_enabled_bucket ? var.existing_kms_key_crn != null ? var.existing_kms_key_crn : module.kms[0].keys[format("%s.%s", local.key_ring_name, local.key_name)].crn : null
  kms_key_id    = var.existing_kms_instance_crn != null ? module.kms[0].keys[format("%s.%s", local.key_ring_name, local.key_name)].key_id : var.existing_kms_key_crn != null ? module.existing_kms_key_crn_parser[0].resource : null

  create_cross_account_auth_policy = var.existing_cloud_logs_crn == null ? !var.skip_cos_kms_iam_auth_policy && var.ibmcloud_kms_api_key == null ? false : true : false
}

module "existing_cos_instance_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_cos_instance_crn
}

module "buckets" {
  providers = {
    ibm = ibm.cos
  }
  depends_on = [time_sleep.wait_for_authorization_policy[0]]
  source     = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version    = "8.19.3"
  bucket_configs = [
    {
      bucket_name              = local.logs_bucket_name
      kms_key_crn              = var.kms_encryption_enabled_bucket ? local.kms_key_crn : null
      kms_guid                 = var.kms_encryption_enabled_bucket ? module.existing_kms_crn_parser[0].service_instance : null
      kms_encryption_enabled   = var.kms_encryption_enabled_bucket
      region_location          = var.region
      resource_instance_id     = var.existing_cos_instance_crn
      management_endpoint_type = var.management_endpoint_type_for_bucket
      storage_class            = var.cloud_logs_cos_buckets_class
    },
    {
      bucket_name                   = local.metrics_bucket_name
      kms_key_crn                   = var.kms_encryption_enabled_bucket ? local.kms_key_crn : null
      kms_guid                      = var.kms_encryption_enabled_bucket ? module.existing_kms_crn_parser[0].service_instance : null
      kms_encryption_enabled        = var.kms_encryption_enabled_bucket
      region_location               = var.region
      resource_instance_id          = var.existing_cos_instance_crn
      management_endpoint_type      = var.management_endpoint_type_for_bucket
      storage_class                 = var.cloud_logs_cos_buckets_class
      skip_iam_authorization_policy = true
    }
  ]
}

module "existing_kms_crn_parser" {
  count   = var.existing_kms_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.existing_kms_instance_crn
}

module "existing_kms_key_crn_parser" {
  count   = local.use_kms_module ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = local.kms_key_crn
}

# Create IAM Authorization Policy to allow COS to access KMS for the encryption key, if cross account KMS is passed in
resource "ibm_iam_authorization_policy" "cos_kms_policy" {
  provider                    = ibm.kms
  count                       = local.create_cross_account_auth_policy ? 1 : 0
  source_service_account      = module.existing_cos_instance_crn_parser.account_id
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = local.cos_instance_guid
  roles                       = ["Reader"]
  description                 = "Allow the COS instance ${local.cos_instance_guid} to read the ${local.kms_service_name} key ${local.kms_key_id} from the instance ${local.existing_kms_guid}"
  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = local.kms_service_name
  }
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.kms_account_id
  }
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.existing_kms_guid
  }
  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "key"
  }
  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = local.kms_key_id
  }
  # Scope of policy now includes the key, so ensure to create new policy before
  # destroying old one to prevent any disruption to every day services.
  lifecycle {
    create_before_destroy = true
  }
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.cos_kms_policy]
  count      = local.create_cross_account_auth_policy ? 1 : 0

  create_duration = "30s"
}

module "kms" {
  providers = {
    ibm = ibm.kms
  }
  count                       = local.use_kms_module ? 1 : 0
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "4.20.0"
  create_key_protect_instance = false
  region                      = local.kms_region
  existing_kms_instance_crn   = var.existing_kms_instance_crn
  key_ring_endpoint_type      = var.kms_endpoint_type
  key_endpoint_type           = var.kms_endpoint_type
  keys = [
    {
      key_ring_name     = local.key_ring_name
      existing_key_ring = false
      keys = [
        {
          key_name                 = local.key_name
          standard_key             = false
          rotation_interval_month  = 3
          dual_auth_delete_enabled = false
          force_delete             = true
        }
      ]
    }
  ]
}

#######################################################################################################################
# Event Notifications
#######################################################################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  # pass_emails = length(var.existing_event_notifications_instances) > 0 && length(var.event_notifications_email_list) == 0 ? tobool("You must pass at least one email address if setting up Event Notifications Integration.") : true

  en_subscription_email = try("${local.prefix}-Email for Cloud Logs Subscription", "Email for Cloud Logs Subscription")
}

data "ibm_en_destinations" "en_destinations" {
  for_each      = { for instance in var.existing_event_notifications_instances : instance.en_instance_id => instance }
  instance_guid = each.key
}

resource "time_sleep" "wait_for_cloud_logs" {
  depends_on      = [module.cloud_logs]
  create_duration = "60s"
}

resource "ibm_en_topic" "en_topic" {
  depends_on    = [time_sleep.wait_for_cloud_logs]
  for_each      = { for instance in var.existing_event_notifications_instances : instance.en_instance_id => instance }
  instance_guid = each.key
  name          = "Topic for Cloud Logs instance ${module.cloud_logs[0].guid}"
  description   = "Topic for Cloud Logs events routing"
  sources {
    id = local.cloud_logs_crn
    rules {
      enabled           = true
      event_type_filter = "$.*"
    }
  }
}

resource "ibm_en_subscription_email" "email_subscription" {
  for_each       = { for instance in var.existing_event_notifications_instances : instance.en_instance_id => instance }
  instance_guid  = each.key
  name           = local.en_subscription_email
  description    = "Subscription for Cloud Logs Events"
  destination_id = [for s in toset(data.ibm_en_destinations.en_destinations[each.key].destinations) : s.id if s.type == "smtp_ibm"][0]
  topic_id       = ibm_en_topic.en_topic[each.key].topic_id
  attributes {
    add_notification_payload = true
    reply_to_mail            = each.value["reply_to_email"]
    reply_to_name            = "Cloud Logs Event Notifications Bot"
    from_name                = each.value["from_email"]
    invited                  = each.value["email_list"]
  }
}
