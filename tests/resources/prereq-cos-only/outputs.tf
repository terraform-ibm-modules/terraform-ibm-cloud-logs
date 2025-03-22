##############################################################################
# Outputs
##############################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
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
