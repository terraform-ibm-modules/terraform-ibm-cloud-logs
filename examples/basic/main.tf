########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.7"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# COS instance
##############################################################################

module "cos" {
  source            = "terraform-ibm-modules/cos/ibm"
  version           = "10.9.6"
  resource_group_id = module.resource_group.resource_group_id
  cos_instance_name = "${var.prefix}-cos"
  cos_tags          = var.resource_tags
  create_cos_bucket = false
}

##############################################################################
# COS buckets
##############################################################################

locals {
  logs_bucket_name    = "${var.prefix}-logs-data"
  metrics_bucket_name = "${var.prefix}-metrics-data"
}

module "buckets" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "10.9.6"
  bucket_configs = [
    {
      bucket_name            = local.logs_bucket_name
      kms_encryption_enabled = false
      region_location        = var.region
      resource_instance_id   = module.cos.cos_instance_id
    },
    {
      bucket_name            = local.metrics_bucket_name
      kms_encryption_enabled = false
      region_location        = var.region
      resource_instance_id   = module.cos.cos_instance_id
    }
  ]
}

########################################################################################################################
# IBM Cloud Logs
########################################################################################################################

#
# Developer tips:
#   - Call the local module / modules in the example to show how they can be consumed
#   - include the actual module source as a code comment like below so consumers know how to consume from correct location
#

locals {
  cloud_logs_instance_name = "${var.prefix}-cloud-logs"
}

module "cloud_logs" {
  source = "../../"
  # delete line above and use below syntax to pull module source from HashiCorp when consuming this module
  # source    = "terraform-ibm-modules/cloud-logs/ibm"
  # version   = "X.Y.Z" # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  instance_name     = local.cloud_logs_instance_name
  resource_tags     = var.resource_tags
  access_tags       = var.access_tags
  data_storage = {
    # logs and metrics buckets must be different
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
}
