variable "akamai_client_secret" {}
variable "akamai_host" {}
variable "akamai_access_token" {}
variable "akamai_client_token" {}
variable "akamai_account_key" {}
variable "cam_key_id" {}
variable "cam_key_guid" {}
variable "version_notes" {
  type    = string
  default = "Tests Performed Locally"
}

# Variables in common to all environments
variable "config_section" {
  type    = string
  default = "default"
}

variable "contract_id" {
  type    = string
  default = "ctr_1-1NC95D"
}

variable "group_name" {
  type    = string
  default = "Demos - Templates"
}

variable "product_id" {
  type    = string
  default = "prd_Download_Delivery"
}

variable "emails" {
  type    = list(string)
  default = ["noreply@akamai.com"]
}

variable "activate_latest_on_staging" {
  type    = bool
  default = false
}

variable "activate_latest_on_production" {
  type    = bool
  default = false
}

# Environment specific variables
variable "property_name" {}
variable "hostname" {}
variable "origin_hostname" {}
variable "edge_hostname" {}
variable "cp_code_name" {}
