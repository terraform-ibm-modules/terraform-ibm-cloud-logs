# IBM Cloud Log Router Agent (v3)

This module configures [IBM Cloud Logs Routing](https://cloud.ibm.com/docs/logs-router) using the **v3 API**. It creates:

1. An IAM service-to-service authorization policy granting the `logs-router` service `Sender` access to a Cloud Logs instance.
2. An `ibm_logs_router_target` — a named, account-global pointer to the Cloud Logs instance CRN.
3. One or more `ibm_logs_router_route` resources — each with ordered rules that filter platform logs by location and forward matching logs to one or more targets.

> **Key v3 concepts**
>
> - **Target** (`ibm_logs_router_target`): account-global resource; references a Cloud Logs instance by CRN.
> - **Route** (`ibm_logs_router_route`): account-global resource; contains up to 10 ordered rules. Each rule has `inclusion_filters` (currently `location`-based) and a list of target IDs to send matching logs to.
> - Rules are evaluated in order; the **first matching rule wins**.

## Usage

```hcl
module "logs_router" {
  source  = "terraform-ibm-modules/cloud-logs/ibm//modules/logs_router"
  version = "X.Y.Z" # Replace "X.Y.Z" with a release version

  cloud_logs_instance_crn = module.cloud_logs.crn
  target_name             = "my-cloud-logs-target"

  routes = [
    {
      name = "us-south-to-cloud-logs"
      rules = [
        {
          action = "send"
          targets = [
            {
              id   = module.log_router_agent.target_id
              crn  = module.log_router_agent.target_crn
              name = module.log_router_agent.target.name
            }
          ]
          inclusion_filters = [
            {
              operand  = "location"
              operator = "is"
              values   = ["us-south"]
            }
          ]
        }
      ]
    }
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.80.2, < 3.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_logs_routing_policy"></a> [logs\_routing\_policy](#module\_logs\_routing\_policy) | terraform-ibm-modules/s2s-auth/ibm | 2.3.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_logs_router_route.routes](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/logs_router_route) | resource |
| [ibm_logs_router_settings.settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/logs_router_settings) | resource |
| [ibm_logs_router_target.targets](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/logs_router_target) | resource |
| [time_sleep.wait_for_auth_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_log_routing_settings"></a> [global\_log\_routing\_settings](#input\_global\_log\_routing\_settings) | Global account settings for logs routing. [Learn more](https://cloud.ibm.com/docs/logs-router?topic=logs-router-settings&interface=ui) | <pre>object({<br/>    default_targets           = optional(list(string), [])<br/>    primary_metadata_region   = optional(string)<br/>    backup_metadata_region    = optional(string)<br/>    permitted_target_regions  = optional(list(string), [])<br/>    private_api_endpoint_only = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | List of log router routes to create. Each route contains an ordered list of rules that are evaluated in sequence; the first matching rule is applied and the rest are skipped. | <pre>list(object({<br/>    name       = string<br/>    managed_by = optional(string, "account")<br/>    rules = list(object({<br/>      action = optional(string, "send")<br/>      targets = list(object({<br/>        id = string<br/>      }))<br/>      inclusion_filters = list(object({<br/>        operand  = string<br/>        operator = string<br/>        values   = list(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | List of IBM Cloud Logs Router targets to create. Each target is a named, account-global pointer to a Cloud Logs instance CRN. | <pre>list(object({<br/>    destination_crn               = string<br/>    target_name                   = string<br/>    target_region                 = optional(string)<br/>    skip_logs_routing_auth_policy = optional(bool, false)<br/>  }))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_logs_router_routes"></a> [logs\_router\_routes](#output\_logs\_router\_routes) | The created IBM Cloud Log Router v3 routes. |
| <a name="output_logs_router_settings"></a> [logs\_router\_settings](#output\_logs\_router\_settings) | The global IBM Cloud Log Router v3 settings. |
| <a name="output_logs_router_targets"></a> [logs\_router\_targets](#output\_logs\_router\_targets) | The created IBM Cloud Log Router v3 targets. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
