##############################################################################
# Resource Group 1
##############################################################################

module "resource_group1" {
  source              = "terraform-ibm-modules/resource-group/ibm"
  version             = "1.3.0"
  resource_group_name = "${var.prefix}-resource-group1"
}

##############################################################################
# Resource Group 2
##############################################################################

module "resource_group2" {
  source              = "terraform-ibm-modules/resource-group/ibm"
  version             = "1.3.0"
  resource_group_name = "${var.prefix}-resource-group2"
}

##############################################################################
# Create Cloud Object Storage instance
##############################################################################

module "cos" {
  source            = "terraform-ibm-modules/cos/ibm"
  version           = "10.2.21"
  resource_group_id = module.resource_group1.resource_group_id
  cos_instance_name = "${var.prefix}-cos"
  cos_tags          = var.resource_tags
  create_cos_bucket = false
}

##############################################################################
# Event Notifications 1
##############################################################################

module "event_notifications1" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "2.7.3"
  resource_group_id = module.resource_group1.resource_group_id
  name              = "${var.prefix}-en1"
  tags              = var.resource_tags
  plan              = "lite"
  region            = var.region
}

##############################################################################
# Event Notifications 2
##############################################################################

module "event_notifications2" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "2.7.3"
  resource_group_id = module.resource_group2.resource_group_id
  name              = "${var.prefix}-en2"
  tags              = var.resource_tags
  plan              = "lite"
  region            = var.region
}
