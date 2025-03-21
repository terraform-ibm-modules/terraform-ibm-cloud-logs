##############################################################################
# Outputs
##############################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group1.resource_group_name
}

output "prefix" {
  value       = var.prefix
  description = "Prefix"
}

output "region" {
  value       = var.region
  description = "region"
}

output "cos_crn" {
  description = "COS CRN"
  value       = module.cos.cos_instance_crn
}

output "en_crns" {
  description = "EN crns"
  value = [{
    en_instance_id = module.event_notifications1.guid,
    en_region = var.region },
    {
      en_instance_id = module.event_notifications2.guid,
      en_region      = var.region
  }]
}
