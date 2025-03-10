########################################################################################################################
# Outputs
########################################################################################################################

#
# Developer tips:
#   - Include all relevant outputs from the modules being called in the example
#

output "crn" {
  value       = module.cloud_logs.crn
  description = "The id of the provisioned Cloud Logs instance."
}

output "guid" {
  value       = module.cloud_logs.guid
  description = "The guid of the provisioned Cloud Logs instance."
}

output "name" {
  value       = module.cloud_logs.name
  description = "The name of the provisioned Cloud Logs instance."
}

output "resource_group_id" {
  value       = module.cloud_logs.resource_group_id
  description = "The resource group where Cloud Logs instance resides."
}

output "ingress_endpoint" {
  value       = module.cloud_logs.ingress_endpoint
  description = "The public ingress endpoint of the provisioned Cloud Logs instance."
}

output "ingress_private_endpoint" {
  value       = module.cloud_logs.ingress_private_endpoint
  description = "The private ingress endpoint of the provisioned Cloud Logs instance."
}
