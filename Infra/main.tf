terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "azuread" {
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
# resource "azurerm_resource_group" "storagerg" {
#   name     = "reststorageaccess-storage-rg"
#   location = "East US"
# }

# resource "azurerm_storage_account" "str" {
#   name                     = var.storageaccname
#   resource_group_name      = azurerm_resource_group.storagerg.name
#   location                 = azurerm_resource_group.storagerg.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"

#   network_rules {
#     default_action             = "Deny"
#     ip_rules                   = var.str_ip_rules
#     virtual_network_subnet_ids = [azurerm_subnet.app_subnet.id]
#   }
# }
data "azurerm_client_config" "current" {
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                       = format("%s-kv",var.webapp_name)
  location                   = azurerm_resource_group.webapp.location
  resource_group_name        = azurerm_resource_group.webapp.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled    = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
      "get",
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
      "purge",
      "recover"
    ]
  }
}

resource "azurerm_key_vault_secret" "appservicesecret" {
  name         = "spn-secret"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.kv.id
}

resource "random_password" "password" {
  length           = 32
  special          = true
  number           = true
  upper            = true
  lower            = true
  override_special = "$-_%@#+="
}

resource "azuread_application_password" "passwrd" {
  application_object_id = var.application_object_id
  description           = "V1"
  value                 = random_password.password.result
  end_date              = timeadd(timestamp(), "8760h") # one year
}

# App Service
resource "azurerm_resource_group" "webapp" {
  name     = "reststorageaccess-webapp-rg"
  location = "East US"
}

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
#       client_secret = var.app_client_secret
#       allowed_audiences = var.allowed_audiences
#     }
#   }
  
# }

# Permission the App Service Idenity to access Storage Account
# azurerm_app_service.strreaderapp.identity.0.principal_id
# azurerm_app_service.example.identity.0.tenant_id