variable "STR_ACC_NAME" {}
variable "WEB_APP_NAME" {}
variable "KV_NAME" {}
variable "RG_NAME" {}
variable "RG_LOCATION" {}
variable "SPN_APP_NAME" {}
variable "ENV" {}
variable "PY_VERSION" {}
variable "str_ip_rules" {
  type = list(string)
  default = []
}
# variable "NETWORK" {
#   type = object({
#     name = string
#     address_space = list(string)
#     rg_name = string
#     subnets = list(object({
#       name = string
#       address_space = list(string)
#       enable_pl_policy = bool
#       delegation = optional(object({
#         name = string
#         actions = list(string)
#       }))
#       }))
#     })
# }

variable "NETWORK" {
  type = object({
    name = string
    address_space = list(string)
    rg_name = string
  })  
}

variable "pep_subnet" {
  type = object({
    name = string
    address_space = list(string)
  })
}

variable "app_subnet" {
  type = object({
    name = string
    address_space = list(string)
  })
}