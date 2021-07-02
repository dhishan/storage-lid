# Network
resource "azurerm_resource_group" "networkrg" {
  name     = var.NETWORK.rg_name
  location = var.RG_LOCATION
}
resource "azurerm_virtual_network" "vnet" {
  name                = var.NETWORK.name
  resource_group_name = azurerm_resource_group.networkrg.name
  location            = azurerm_resource_group.networkrg.location
  address_space       = var.NETWORK.address_space
}

# resource "azurerm_subnet" "app_subnet" {
#   count = length(var.NETWORK.subnets)
#   name                 = var.NETWORK.subnets[count.index].name
#   resource_group_name  = azurerm_resource_group.networkrg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = var.NETWORK.subnets[count.index].address_space
#   enforce_private_link_endpoint_network_policies = var.NETWORK.subnets[count.index].enable_pl_policy

#   dynamic "delegation" {
#       for_each = var.NETWORK.subnets[count.index].delegation == null ? [] : [1]
#       content {
#             name = "delegation"
#             service_delegation {
#                 name = var.NETWORK.subnets[count.index].delegation.name
#                 actions = var.NETWORK.subnets[count.index].delegation.actions
#             }
#       }
#   }
# }

resource "azurerm_subnet" "app_subnet" {
  name                 = var.app_subnet.name
  resource_group_name  = azurerm_resource_group.networkrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.app_subnet.address_space

  delegation {
    name = "webapp_delegation"
    service_delegation {
        name = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet" "pep_subnet" {
  name                 = var.pep_subnet.name
  resource_group_name  = azurerm_resource_group.networkrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.pep_subnet.address_space
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_dns_zone" "dnszone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.networkrg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnetlink" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.networkrg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnszone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "pep" {
  name                = format("%s-endpoint",var.STR_ACC_NAME)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.pep_subnet.id

  private_service_connection {
    name                              = format("%s-endpoint-connection",var.STR_ACC_NAME)
    private_connection_resource_id    = azurerm_storage_account.str.id
    is_manual_connection              = false
    subresource_names                 = ["blob"]
  }

  private_dns_zone_group {
      name                            = var.ENV
      private_dns_zone_ids            = [azurerm_private_dns_zone.dnszone.id]
  }
}


