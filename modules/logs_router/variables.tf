##############################################################################
# variables
##############################################################################

variable "cloud_logs_instance_crn" {
  type        = string
  description = "The CRN of the IBM Cloud Logs instance that log router targets will forward platform logs to."
}

variable "target_name" {
  type        = string
  description = "The name to assign to the ibm_logs_router_target resource."

  validation {
    condition     = length(var.target_name) >= 1 && length(var.target_name) <= 1000
    error_message = "target_name must be between 1 and 1000 characters."
  }
}

variable "skip_logs_routing_auth_policy" {
  type        = bool
  description = "Set to true to skip creating the IAM service-to-service authorization policy that grants Logs Routing 'Sender' access to the Cloud Logs instance. Set to true only when the policy already exists."
  default     = false
}

variable "routes" {
  type = list(object({
    name       = string
    managed_by = optional(string)
    rules = list(object({
      action = optional(string, "send")
      targets = list(object({
        id = string
      }))
      inclusion_filters = list(object({
        operand  = string
        operator = string
        values   = list(string)
      }))
    }))
  }))
  description = "List of log router routes to create. Each route contains an ordered list of rules that are evaluated in sequence; the first matching rule is applied and the rest are skipped."
  default     = []

  validation {
    condition     = alltrue([for r in var.routes : length(r.name) >= 1 && length(r.name) <= 1000])
    error_message = "Each route name must be between 1 and 1000 characters."
  }

  validation {
    condition     = alltrue([for r in var.routes : r.managed_by == null || contains(["enterprise", "account"], r.managed_by)])
    error_message = "Each route managed_by must be 'enterprise' or 'account' when set."
  }

  validation {
    condition     = alltrue([for r in var.routes : length(r.rules) >= 1 && length(r.rules) <= 10])
    error_message = "Each route must have between 1 and 10 rules."
  }

  validation {
    condition = alltrue([
      for r in var.routes : alltrue([
        for rule in r.rules : contains(["send", "drop"], rule.action)
      ])
    ])
    error_message = "Each rule action must be 'send' or 'drop'."
  }

  validation {
    condition = alltrue([
      for r in var.routes : alltrue([
        for rule in r.rules : alltrue([
          for f in rule.inclusion_filters : contains(["location"], f.operand)
        ])
      ])
    ])
    error_message = "inclusion_filter operand must be 'location'."
  }

  validation {
    condition = alltrue([
      for r in var.routes : alltrue([
        for rule in r.rules : alltrue([
          for f in rule.inclusion_filters : contains(["is", "in"], f.operator)
        ])
      ])
    ])
    error_message = "inclusion_filter operator must be 'is' or 'in'."
  }

  validation {
    condition = alltrue([
      for r in var.routes : alltrue([
        for rule in r.rules : alltrue([
          for f in rule.inclusion_filters : length(f.values) >= 1 && length(f.values) <= 20
        ])
      ])
    ])
    error_message = "Each inclusion_filter must have between 1 and 20 values."
  }
}

variable "global_log_routing_settings" {
  type = object({
    default_targets           = optional(list(string), [])
    primary_metadata_region   = optional(string)
    backup_metadata_region    = optional(string)
    permitted_target_regions  = optional(list(string), [])
    private_api_endpoint_only = optional(bool, false)
  })
  description = "Global account settings for logs routing. [Learn more](https://cloud.ibm.com/docs/logs-router?topic=logs-router-settings&interface=ui)"
  default     = null

  validation {
    error_message = "Valid regions for `permitted_target_regions` to control where targets collecting platform logs can be located are: us-south, eu-de, us-east, eu-es, eu-gb, au-syd, br-sao, ca-tor, ca-mon, eu-es, jp-tok, jp-osa, in-che, in-mum, eu-fr2"
    condition = (var.global_log_routing_settings == null ?
      true :
      alltrue([
        for region in var.global_log_routing_settings.permitted_target_regions :
        contains(["us-south", "eu-de", "us-east", "eu-es", "eu-gb", "au-syd", "br-sao", "ca-tor", "ca-mon", "eu-es", "jp-tok", "jp-osa", "in-che", "in-mum", "eu-fr2"], region)
      ])
    )
  }
}
