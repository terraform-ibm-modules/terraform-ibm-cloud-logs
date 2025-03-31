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
  prefix                  = var.prefix != null ? (var.prefix != "" ? var.prefix : null) : null
  logs_bucket_crn         = var.existing_logs_cos_bucket_name == null ? module.buckets[0].buckets[local.logs_bucket_name].bucket_crn : data.ibm_cos_bucket.existing_logs_bucket[0].crn
  metrics_bucket_crn      = var.existing_metrics_cos_bucket_name == null ? module.buckets[0].buckets[local.metrics_bucket_name].bucket_crn : data.ibm_cos_bucket.existing_metrics_bucket[0].crn
  logs_bucket_endpoint    = var.existing_logs_cos_bucket_name == null ? module.buckets[0].buckets[local.logs_bucket_name].s3_endpoint_direct : data.ibm_cos_bucket.existing_logs_bucket[0].s3_endpoint_direct
  metrics_bucket_endpoint = var.existing_metrics_cos_bucket_name == null ? module.buckets[0].buckets[local.metrics_bucket_name].s3_endpoint_direct : data.ibm_cos_bucket.existing_metrics_bucket[0].s3_endpoint_direct
  create_cloud_logs       = var.existing_cloud_logs_crn == null
  cloud_logs_crn          = local.create_cloud_logs ? module.cloud_logs[0].crn : var.existing_cloud_logs_crn
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
      bucket_crn      = local.logs_bucket_crn
      bucket_endpoint = local.logs_bucket_endpoint
    },
    metrics_data = {
      enabled         = true
      bucket_crn      = local.metrics_bucket_crn
      bucket_endpoint = local.metrics_bucket_endpoint
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
  # tflint-ignore: terraform_unused_declarations
  pass_two_existing_buckets = (var.existing_logs_cos_bucket_name != null && var.existing_metrics_cos_bucket_name == null) || (var.existing_logs_cos_bucket_name == null && var.existing_metrics_cos_bucket_name != null) ? tobool("If passing in existing buckets, values for both logs and metrics values need to be passed.") : true
  # tflint-ignore: terraform_unused_declarations
  pass_all_logs_bucket_information = var.existing_logs_cos_bucket_name != null && var.existing_logs_cos_bucket_region == null ? tobool("If passing a value for 'existing_logs_cos_bucket_name', a value for 'existing_logs_cos_bucket_region' needs to be passed as well.") : true
  # tflint-ignore: terraform_unused_declarations
  pass_all_metrics_bucket_information = var.existing_metrics_cos_bucket_name != null && var.existing_metrics_cos_bucket_region == null ? tobool("If passing a value for 'existing_metrics_cos_bucket_name', a value for 'existing_metrics_cos_bucket_region' needs to be passed as well.") : true

  kms_encryption_enabled = var.existing_kms_instance_crn != null
  create_buckets         = local.create_cloud_logs && var.existing_logs_cos_bucket_name == null && var.existing_metrics_cos_bucket_name == null
  use_kms_module         = local.create_buckets && local.kms_encryption_enabled && var.existing_kms_key_crn == null

  logs_bucket_name    = try("${local.prefix}-${var.new_logs_cos_bucket_name}", var.new_logs_cos_bucket_name)
  metrics_bucket_name = try("${local.prefix}-${var.new_metrics_cos_bucket_name}", var.new_metrics_cos_bucket_name)
  key_ring_name       = try("${local.prefix}-${var.cloud_log_storage_key_ring}", var.cloud_log_storage_key_ring)
  key_name            = try("${local.prefix}-${var.cloud_log_storage_key}", var.cloud_log_storage_key)
  kms_key_crn         = local.kms_encryption_enabled ? var.existing_kms_key_crn != null ? var.existing_kms_key_crn : module.kms[0].keys[format("%s.%s", local.key_ring_name, local.key_name)].crn : null
}

module "buckets" {
  count   = local.create_buckets ? 1 : 0
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "8.19.3"
  bucket_configs = [
    {
      bucket_name                         = local.logs_bucket_name
      kms_key_crn                         = local.kms_encryption_enabled ? local.kms_key_crn : null
      kms_guid                            = local.kms_encryption_enabled ? module.existing_kms_crn_parser[0].service_instance : null
      kms_encryption_enabled              = local.kms_encryption_enabled
      region_location                     = var.region
      resource_instance_id                = var.existing_cos_instance_crn
      management_endpoint_type_for_bucket = var.management_endpoint_type_for_bucket
    },
    {
      bucket_name                         = local.metrics_bucket_name
      kms_key_crn                         = local.kms_encryption_enabled ? local.kms_key_crn : null
      kms_guid                            = local.kms_encryption_enabled ? module.existing_kms_crn_parser[0].service_instance : null
      kms_encryption_enabled              = local.kms_encryption_enabled
      region_location                     = var.region
      resource_instance_id                = var.existing_cos_instance_crn
      management_endpoint_type_for_bucket = var.management_endpoint_type_for_bucket
      skip_iam_authorization_policy       = true
    }
  ]
}

data "ibm_cos_bucket" "existing_logs_bucket" {
  count                = local.create_buckets ? 0 : 1
  bucket_name          = var.existing_logs_cos_bucket_name
  resource_instance_id = var.existing_cos_instance_crn
  bucket_region        = var.existing_logs_cos_bucket_region
  bucket_type          = var.existing_logs_cos_bucket_type
}

data "ibm_cos_bucket" "existing_metrics_bucket" {
  count                = local.create_buckets ? 0 : 1
  bucket_name          = var.existing_metrics_cos_bucket_name
  resource_instance_id = var.existing_cos_instance_crn
  bucket_region        = var.existing_metrics_cos_bucket_region
  bucket_type          = var.existing_metrics_cos_bucket_type
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

module "kms" {
  count                       = local.use_kms_module ? 1 : 0
  source                      = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                     = "4.20.0"
  create_key_protect_instance = false
  region                      = module.existing_kms_crn_parser[0].region
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
  pass_emails = length(var.existing_event_notifications_instances) > 0 && length(var.event_notifications_email_list) == 0 ? tobool("You must pass at least one email address if setting up Event Notifications Integration.") : true

  en_topic              = try("${local.prefix}-Cloud Logs Topic", "Cloud Logs Topic")
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
  name          = local.en_topic
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
    reply_to_mail            = var.event_notifications_reply_to_email
    reply_to_name            = "Cloud Logs Event Notifications Bot"
    from_name                = var.event_notifications_from_email
    invited                  = var.event_notifications_email_list
  }
}
