##############################################################################
# Input Variables
##############################################################################

variable "use_private_endpoint" {
  type        = bool
  description = "Set to true to use the private endpoints instead of public endpoints for IBM Cloud Logs Router service. When true, the script queries the private Logs Router endpoint. [Learn more](https://cloud.ibm.com/docs/logs-router?topic=logs-router-endpoints)"
  default     = false
}
