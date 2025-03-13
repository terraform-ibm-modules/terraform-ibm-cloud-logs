##############################################################################
# Outputs
##############################################################################

output "cloud_logs_crn" {
  value       = local.cloud_logs_crn
  description = "The id of the provisioned Cloud Logs instance."
}

output "cloud_logs_guid" {
  value       = local.create_cloud_logs ? module.cloud_logs[0].guid : null
  description = "The guid of the provisioned Cloud Logs instance."
}

output "cloud_logs_name" {
  value       = local.create_cloud_logs ? module.cloud_logs[0].name : null
  description = "The name of the provisioned Cloud Logs instance."
}

output "cloud_logs_ingress_endpoint" {
  value       = local.create_cloud_logs ? module.cloud_logs[0].ingress_endpoint : null
  description = "The public ingress endpoint of the provisioned Cloud Logs instance."
}

output "cloud_logs_ingress_private_endpoint" {
  value       = local.create_cloud_logs ? module.cloud_logs[0].ingress_private_endpoint : null
  description = "The private ingress endpoint of the provisioned Cloud Logs instance."
}

output "cloud_logs_logs_policies_details" {
  value       = local.create_cloud_logs ? module.cloud_logs[0].logs_policies_details : null
  description = "The details of the Cloud logs policies created."
}

output "logs_bucket_crn" {
  description = "Logs Cloud Object Storage bucket CRN"
  value       = local.create_buckets ? module.buckets[0].buckets[local.logs_bucket_name].bucket_crn : null
}

output "metrics_bucket_crn" {
  description = "Metrics Cloud Object Storage bucket CRN"
  value       = local.create_buckets ? module.buckets[0].buckets[local.metrics_bucket_name].bucket_crn : null
}

output "logs_bucket_name" {
  description = "Logs Cloud Object Storage bucket name"
  value       = local.create_buckets ? local.logs_bucket_name : null
}

output "metrics_bucket_name" {
  description = "Metrics Cloud Object Storage bucket name"
  value       = local.create_buckets ? local.metrics_bucket_name : null
}

output "kms_key_crn" {
  description = "The CRN of the KMS key used to encrypt the COS bucket"
  value       = local.kms_key_crn
}
