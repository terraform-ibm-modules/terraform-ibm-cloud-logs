output "crn" {
  value       = ibm_resource_instance.cloud_logs.id
  description = "The CRN of the provisioned IBM Cloud Logs instance."
}

output "guid" {
  value       = ibm_resource_instance.cloud_logs.guid
  description = "The guid of the provisioned IBM Cloud Logs instance."
}

output "account_id" {
  value       = ibm_resource_instance.cloud_logs.account_id
  description = "The account id where IBM Cloud logs instance is provisioned."
}

output "name" {
  value       = ibm_resource_instance.cloud_logs.name
  description = "The name of the provisioned IBM Cloud Logs instance."
}

output "resource_group_id" {
  value       = ibm_resource_instance.cloud_logs.resource_group_id
  description = "The resource group where IBM Cloud Logs instance resides."
}

output "ingress_endpoint" {
  value       = ibm_resource_instance.cloud_logs.extensions.external_ingress
  description = "The public ingress endpoint of the provisioned IBM Cloud Logs instance."
}

output "ingress_private_endpoint" {
  value       = ibm_resource_instance.cloud_logs.extensions.external_ingress_private
  description = "The private ingress endpoint of the provisioned IBM Cloud Logs instance."
}

output "logs_policies_details" {
  value       = length(var.policies) > 0 ? module.logs_policies[0].logs_policies_details : null
  description = "The details of the IBM Cloud logs policies created."
}
