##############################################################################
# Resource Group 1
##############################################################################

module "resource_group1" {
  source              = "terraform-ibm-modules/resource-group/ibm"
  version             = "1.1.6"
  resource_group_name = "${var.prefix}-resource-group1"
}

##############################################################################
# Resource Group 2
##############################################################################

module "resource_group2" {
  source              = "terraform-ibm-modules/resource-group/ibm"
  version             = "1.1.6"
  resource_group_name = "${var.prefix}-resource-group2"
}

##############################################################################
# Resource Group 3
##############################################################################

module "resource_group3" {
  source              = "terraform-ibm-modules/resource-group/ibm"
  version             = "1.1.6"
  resource_group_name = "${var.prefix}-resource-group3"
}

##############################################################################
# Create Cloud Object Storage instance
##############################################################################

module "cos" {
  source            = "terraform-ibm-modules/cos/ibm"
  version           = "8.19.5"
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
  version           = "1.18.8"
  resource_group_id = module.resource_group1.resource_group_id
  name              = "${var.prefix}-en1"
  tags              = var.resource_tags
  plan              = "lite"
  region            = "us-south"
}

##############################################################################
# Event Notifications 2
##############################################################################

module "event_notifications2" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "1.18.8"
  resource_group_id = module.resource_group2.resource_group_id
  name              = "${var.prefix}-en2"
  tags              = var.resource_tags
  plan              = "lite"
  region            = "eu-gb"
}

##############################################################################
# Event Notifications 3
##############################################################################

module "event_notifications3" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "1.18.8"
  resource_group_id = module.resource_group3.resource_group_id
  name              = "${var.prefix}-en3"
  tags              = var.resource_tags
  plan              = "lite"
  region            = "au-syd"
}
