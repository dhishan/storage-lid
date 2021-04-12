output "app_object_id" {
  value = azuread_application.app.object_id
}

output "app_app_id" {
  value = azuread_application.app.application_id
}

output "kv_name" {
  value = azurerm_key_vault.kv.name
}

output "kv_id" {
  value = azurerm_key_vault.kv.id
}

output "rg_id" {
  value = azurerm_resource_group.rg.id
}
