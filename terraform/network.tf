# Network
# resource "azurerm_resource_group" "network" {
#   name     = "reststorageaccess-network-rg"
#   location = "East US"
# }

# resource "azurerm_virtual_network" "vnet" {
#   name                = "webapp-network"
#   resource_group_name = azurerm_resource_group.network.name
#   location            = azurerm_resource_group.network.location
#   address_space       = ["10.145.0.0/16"]
# }

# resource "azurerm_subnet" "app_subnet" {
#   name                 = "app-service-subnet"
#   resource_group_name  = azurerm_resource_group.network.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

