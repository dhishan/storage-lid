variable "storageaccname" {
    default = "orguserdatastore"
}

variable "str_ip_rules" {
    type = list(string)
    default = [
        "71.172.157.44"
    ]
}

variable "webapp_name" {
  default = "strreaderapp"
}

variable "application_object_id" {
  type = string
}