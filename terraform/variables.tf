variable "storageaccname" {
    default = "orguserdatastore"
}

variable "str_ip_rules" {
    type = list(string)
}

variable "webapp_name" {
  default = "strreaderapp"
}

variable "kv_name" {
  default = "strreaderkv"
}

variable "rg_name" {
  type = string
}

variable "rg_location" {
  type = string
}

variable "app_name" {
  type = string
}