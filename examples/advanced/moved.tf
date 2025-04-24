moved {
  from = module.cloud_logs.ibm_iam_authorization_policy.en_policy
  to   = module.cloud_logs.module.en_integration.ibm_iam_authorization_policy.en_policy
}

moved {
  from = module.cloud_logs.ibm_logs_outgoing_webhook.en_integration
  to   = module.cloud_logs.module.en_integration.ibm_logs_outgoing_webhook.en_integration
}

moved {
  from = module.cloud_logs.ibm_logs_policy.logs_policies
  to   = module.cloud_logs.module.logs_policies.ibm_logs_policy.logs_policies
}

moved {
  from = module.cloud_logs.time_sleep.wait_for_en_authorization_policy
  to   = module.cloud_logs.module.en_integration.time_sleep.wait_for_en_authorization_policy
}
