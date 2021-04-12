terraform {
  backend "azurerm" {
    resource_group_name  = "statefiles-store-rg"
    storage_account_name = "statefilesstore"
    container_name       = "storage-lid"
    key                  = "App.tfstate"
  }
}


# terraform {
#   backend "azurerm" {}
# }

provider "azurerm" {
  features {}
}

provider "azuread" {
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_key_vault" "kv" {
  name                = var.kv_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault_secret" "kv_secret" {
  name         = var.kv_secret_name
  key_vault_id = data.azurerm_key_vault.kv.id
}

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

# Storage
resource "azurerm_storage_account" "str" {
  name                     = var.storageaccname
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.str_ip_rules
    # virtual_network_subnet_ids = [azurerm_subnet.app_subnet.id]
  }
}


# App Service


# resource "azurerm_app_service_plan" "appserviceplan" {
#   name                = format("%s-plan", var.webapp_name)
#   location            = azurerm_resource_group.webapp.location
#   resource_group_name = azurerm_resource_group.webapp.name

#   sku {
#     tier = "Basic"
#     size = "B1"
#   }
# }

# resource "azurerm_app_service" "strreaderapp" {
#   name                = var.webapp_name
#   location            = azurerm_resource_group.webapp.location
#   resource_group_name = azurerm_resource_group.webapp.name
#   app_service_plan_id = azurerm_app_service_plan.appserviceplan.id

#   site_config {
#     linux_fx_version = "PYTHON|3.7"
#   }

#   app_settings = {
#     "STORAGE_URI" = azurerm_storage_account.str.primary_blob_endpoint
#   }

#   identity {
#     type = "SystemAssigned"
#   }

#   auth_settings {
#     enabled = true
#     active_directory {
#       client_id = var.app_client_id
#       client_secret = data.azurerm_key_vault_secret.kv_secret.value
#       allowed_audiences = var.allowed_audiences
#     }
#   }
  
# }

# Permission the App Service Idenity to access Storage Account
# azurerm_app_service.strreaderapp.identity.0.principal_id
# azurerm_app_service.example.identity.0.tenant_id