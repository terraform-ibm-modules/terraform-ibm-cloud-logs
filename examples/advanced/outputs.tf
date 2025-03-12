##############################################################################
# Outputs
##############################################################################

#
# Developer tips:
#   - Include all relevant outputs from the modules being called in the example
#

output "cloud_logs_crn" {
  value       = module.cloud_logs.crn
  description = "The id of the provisioned Cloud Logs instance."
}

output "cloud_logs_guid" {
  value       = module.cloud_logs.guid
  description = "The guid of the provisioned Cloud Logs instance."
}

output "cloud_logs_name" {
  value       = module.cloud_logs.name
  description = "The name of the provisioned Cloud Logs instance."
}

output "resource_group_id" {
  value       = module.cloud_logs.resource_group_id
  description = "The resource group where Cloud Logs instance resides."
}

output "cloud_logs_ingress_endpoint" {
  value       = module.cloud_logs.ingress_endpoint
  description = "The public ingress endpoint of the provisioned Cloud Logs instance."
}

output "cloud_logs_ingress_private_endpoint" {
  value       = module.cloud_logs.ingress_private_endpoint
  description = "The private ingress endpoint of the provisioned Cloud Logs instance."
}

output "cos_crn" {
  value       = module.cos.cos_instance_id
  description = "The id of the provisioned Cloud Object Storage instance."
}

output "logs_bucket_crn" {
  value       = module.buckets.buckets[local.logs_bucket_name].bucket_crn
  description = "The id of the provisioned Cloud Object Storage bucket for logs."
}

output "logs_bucket_name" {
  value       = local.logs_bucket_name
  description = "The name of the provisioned Cloud Object Storage bucket for logs."
}

output "metrics_bucket_crn" {
  value       = module.buckets.buckets[local.metrics_bucket_name].bucket_crn
  description = "The id of the provisioned Cloud Object Storage bucket for metrics."
}

output "metrics_bucket_name" {
  value       = local.metrics_bucket_name
  description = "The name of the provisioned Cloud Object Storage bucket for metrics."
}

output "event_notification_1_crn" {
  value       = module.event_notification_1.crn
  description = "The id of the provisioned Event Notifications 1 instance."
}

output "event_notification_2_crn" {
  value       = module.event_notification_2.crn
  description = "The id of the provisioned Event Notifications 2 instance."
}
