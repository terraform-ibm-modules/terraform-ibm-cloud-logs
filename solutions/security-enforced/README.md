# IBM Cloud Cloud Logs deployable architecture - Enforced Security

This deployable architecture creates a Cloud Logs instance in IBM Cloud and supports provisioning the following resources:

* The root keys in an existing key management service (KMS) if the keys do not exist. These keys are used when Object Storage buckets are created.
* A KMS-encrypted Object Storage bucket in an existing Cloud Object Storage instance for Cloud Logs data.
* A KMS-encrypted Object Storage bucket in an existing Cloud Object Storage instance for Cloud Logs metrics.
* An option to configure Cloud logs policies (TCO Optimizer).

![cloud-logs-deployable-architecture]()

**Important:** Because this solution contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments, do not call this solution from one or more other modules. For more information about how resources are associated with provider configurations with multiple modules, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).
