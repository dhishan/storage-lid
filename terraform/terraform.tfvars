RG_NAME = "storage-lid-pe-rg"
KV_NAME     = "storagelidpekv"
RG_LOCATION = "East US"
SPN_APP_NAME    = "storage-lid-pe"
WEB_APP_NAME = "storage-lid-pe"
STR_ACC_NAME = "orguserdatastorepe"
NETWORK = {
    name = "storage-lid-vnet"
    address_space = ["10.0.0.0/16"]
    rg_name = "storage-lid-vnet-rg"
    subnets = [{
        name = "app-subnet"
        address_space = ["10.0.1.0/24"]
        enable_pl_policy = true
    }]
}
ENV = "dev"