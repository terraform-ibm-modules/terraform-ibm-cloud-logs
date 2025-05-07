moved {
  from = ibm_iam_authorization_policy.en_policy
  to   = module.en_integration[0].ibm_iam_authorization_policy.en_policy
}

moved {
  from = ibm_logs_outgoing_webhook.en_integration
  to   = module.en_integration[0].ibm_logs_outgoing_webhook.en_integration
}

moved {
  from = ibm_logs_policy.logs_policies
  to   = module.logs_policies[0].ibm_logs_policy.logs_policies
}

moved {
  from = time_sleep.wait_for_en_authorization_policy
  to   = module.en_integration[0].time_sleep.wait_for_en_authorization_policy
}
