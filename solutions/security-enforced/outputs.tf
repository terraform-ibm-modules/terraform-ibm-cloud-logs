##############################################################################
# Outputs
##############################################################################

output "cloud_logs_crn" {
  value       = module.security_enforced.cloud_logs_crn
  description = "The id of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_guid" {
  value       = module.security_enforced.cloud_logs_guid
  description = "The guid of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_name" {
  value       = module.security_enforced.cloud_logs_name
  description = "The name of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_ingress_endpoint" {
  value       = module.security_enforced.cloud_logs_ingress_endpoint
  description = "The public ingress endpoint of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_ingress_private_endpoint" {
  value       = module.security_enforced.cloud_logs_ingress_private_endpoint
  description = "The private ingress endpoint of the provisioned IBM Cloud Logs instance."
}

output "cloud_logs_logs_policies_details" {
  value       = module.security_enforced.cloud_logs_logs_policies_details
  description = "The details of the IBM Cloud logs policies created."
}

output "logs_bucket_crn" {
  description = "Logs Cloud Object Storage bucket CRN"
  value       = module.security_enforced.logs_bucket_crn
}

output "metrics_bucket_crn" {
  description = "Metrics Cloud Object Storage bucket CRN"
  value       = module.security_enforced.metrics_bucket_crn
}

output "logs_bucket_name" {
  description = "Logs Cloud Object Storage bucket name"
  value       = module.security_enforced.logs_bucket_name
}

output "metrics_bucket_name" {
  description = "Metrics Cloud Object Storage bucket name"
  value       = module.security_enforced.metrics_bucket_name
}

output "kms_key_crn" {
  description = "The CRN of the KMS key used to encrypt the COS bucket"
  value       = module.security_enforced.kms_key_crn
}

output "next_steps_text" {
  value       = "Your Cloud Log Instance is ready."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to Cloud Log Instance"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = module.security_enforced.next_step_primary_url
  description = "Primary URL for the IBM Cloud Logs instance"
}
