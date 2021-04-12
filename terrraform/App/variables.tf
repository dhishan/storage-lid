variable "storageaccname" {
    default = "orguserdatastore"
}

variable "str_ip_rules" {
    type = list(string)
    default = [
        "72.76.142.107"
    ]
}

variable "webapp_name" {
  default = "strreaderapp"
}

variable "application_object_id" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "kv_name" {
  type = string
}

variable "kv_secret_name" {
  type = string
}

variable "app_client_id" {
  type = string
}

variable "name" {
  
}