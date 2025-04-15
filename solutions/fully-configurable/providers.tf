########################################################################################################################
# Provider config
########################################################################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  visibility       = var.provider_visibility
}

provider "ibm" {
  alias            = "kms"
  ibmcloud_api_key = var.ibmcloud_kms_api_key != null ? var.ibmcloud_kms_api_key : var.ibmcloud_api_key
  region           = local.kms_region
  visibility       = var.provider_visibility
}

provider "ibm" {
  alias            = "cos"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  visibility       = var.provider_visibility
}

provider "ibm" {
  alias            = "en-au-syd"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = "au-syd"
  visibility       = var.provider_visibility
}

provider "ibm" {
  alias            = "en-eu-de"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = "eu-de"
  visibility       = var.provider_visibility
}

provider "ibm" {
  alias            = "en-eu-es"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = "eu-es"
  visibility       = var.provider_visibility
}

provider "ibm" {
  alias            = "en-eu-gb"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = "eu-gb"
  visibility       = var.provider_visibility
}

provider "ibm" {
  alias            = "en-us-south"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = "us-south"
  visibility       = var.provider_visibility
}
