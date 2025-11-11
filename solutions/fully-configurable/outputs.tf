##############################################################################
# Outputs
##############################################################################

output "cloud_logs_crn" {
  value       = local.cloud_logs_crn
  description = "The id of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_guid" {
  value       = local.create_cloud_logs ? module.cloud_logs[0].guid : null
  description = "The guid of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_name" {
  value       = local.create_cloud_logs ? module.cloud_logs[0].name : null
  description = "The name of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_ingress_endpoint" {
  value       = local.create_cloud_logs ? module.cloud_logs[0].ingress_endpoint : null
  description = "The public ingress endpoint of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_ingress_private_endpoint" {
  value       = local.create_cloud_logs ? module.cloud_logs[0].ingress_private_endpoint : null
  description = "The private ingress endpoint of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_logs_policies_details" {
  value       = local.create_cloud_logs ? module.cloud_logs[0].logs_policies_details : null
  description = "The details of the IBM Cloud logs policies created."
}

output "logs_bucket_crn" {
  description = "Logs Cloud Object Storage bucket CRN"
  value       = module.buckets.buckets[local.data_bucket_name].bucket_crn
}

output "metrics_bucket_crn" {
  description = "Metrics Cloud Object Storage bucket CRN"
  value       = module.buckets.buckets[local.metrics_bucket_name].bucket_crn
}

output "logs_bucket_name" {
  description = "Logs Cloud Object Storage bucket name"
  value       = module.buckets.buckets[local.data_bucket_name].bucket_name
}

output "metrics_bucket_name" {
  description = "Metrics Cloud Object Storage bucket name"
  value       = module.buckets.buckets[local.metrics_bucket_name].bucket_name
}

output "kms_key_crn" {
  description = "The CRN of the KMS key used to encrypt the COS bucket"
  value       = local.kms_key_crn
}

output "next_steps_text" {
  value       = "Your Cloud Log Instance is ready."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to Cloud Logs instance"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = local.create_cloud_logs ? "https://cloud.ibm.com/observability/logging/${module.cloud_logs[0].guid}/overview" : "https://cloud.ibm.com/observability/logging/${element(split(":", var.existing_cloud_logs_crn), 7)}/overview"
  description = "Primary URL for the IBM Cloud Logs instance"
}
