variable "STR_ACC_NAME" {}
variable "WEB_APP_NAME" {}
variable "KV_NAME" {}
variable "RG_NAME" {}
variable "RG_LOCATION" {}
variable "SPN_APP_NAME" {}
variable "ENV" {}
variable "str_ip_rules" {
  type = list(string)
  default = []
}
variable "NETWORK" {
  type = object({
    name = string
    address_space = list(string)
    rg_name = string
    subnets = list(object({
      name = string
      address_space = list(string)
      enable_pl_policy = bool
    }))
  })
}