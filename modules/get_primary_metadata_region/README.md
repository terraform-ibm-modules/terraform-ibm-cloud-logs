# Primary Metadata Region

This module retrieves the `primary_metadata_region` value from the IBM Cloud Logs Router Account Settings.

### Customizing default cloud service endpoints

The user must export the endpoint as an environment variable in order to use custom cloud service endpoints with this module. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints#getting-started-with-custom-service-endpoints).

**Important** The only supported method for customizing cloud service endpoints is to export the environment variables endpoint; be sure to export the value for `IBMCLOUD_LOGS_ROUTING_API_ENDPOINT`. For example,

```
export IBMCLOUD_LOGS_ROUTING_API_ENDPOINT="<endpoint_url>"
```

## Usage

```hcl

provider "ibm" {
  ibmcloud_api_key      = "XXXXXXXXXXXXXXXXXXXXXXXX"  # pragma: allowlist secret
}

module "primary_metadata_region" {
  source               = "terraform-ibm-modules/cloud-logs/ibm//modules/get_primary_metadata_region"
  use_private_endpoint = false
}
```

### Required IAM access policies

You need the following permissions to run this module.

* Service
  * **IBM Cloud Logs Router**
    * `Viewer` platform access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >= 2.3.5, <3.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.80.2, < 3.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [external_external.get_primary_metadata_region](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [ibm_iam_auth_token.token](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/iam_auth_token) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_use_private_endpoint"></a> [use\_private\_endpoint](#input\_use\_private\_endpoint) | Set to true to use the private endpoints instead of public endpoints for IBM Cloud Logs Router service. When true, the script queries the private Logs Router endpoint. [Learn more](https://cloud.ibm.com/docs/logs-router?topic=logs-router-endpoints) | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_metadata_region"></a> [primary\_metadata\_region](#output\_primary\_metadata\_region) | The current primary metadata region set for IBM Cloud Logs Router. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
