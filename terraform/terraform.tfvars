# RG_NAME = "storage-lid-pe-rg"
# KV_NAME     = "storagelidpekv"
# RG_LOCATION = "East US"
# SPN_APP_NAME    = "storage-lid-pe"
# WEB_APP_NAME = "storage-lid-pe"
# STR_ACC_NAME = "orguserdatastorepe"
# ENV = "dev"
# 
# NETWORK = {
#     name = "storage-lid-vnet"
#     address_space = ["10.0.0.0/16"]
#     rg_name = "storage-lid-vnet-rg"
#     subnets = [{
#         name = "pep-subnet"
#         address_space = ["10.0.1.0/24"]
#         enable_pl_policy = true
#     }
#     ,{
#         name = "webapp-subnet",
#         address_space = ["10.0.2.0/24"]
#         enable_pl_policy = false
#         delegation = {
#             name = "Microsoft.Web/serverFarms"
#             actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
#         }
#     }
#     ]
# }
str_ip_rules = ["72.76.142.107"]

NETWORK = {
    name = "storage-lid-vnet"
    address_space = ["10.0.0.0/16"]
    rg_name = "storage-lid-vnet-rg"
}

pep_subnet = {
    name = "pep_subnet"
    address_space = ["10.0.0.0/24"]
}

app_subnet = {
    name = "app_subnet"
    address_space = ["10.0.1.0/24"]
}