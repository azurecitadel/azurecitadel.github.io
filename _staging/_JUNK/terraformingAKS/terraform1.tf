provider "azurerm" {
  subscription_id = "2ca40be1-7e80-4f2b-92f7-06b2123a68cc"
  client_id       = "742284b5-44bb-493d-a7b7-14dbc7e52abd"
  client_secret   = "d4425bff-1202-4646-89db-17f2dabef4dd"
  tenant_id       = "72f988bf-86f1-41af-91ab-2d7cd011db47"
}

resource "azurerm_resource_group" "testrg" {
  name     = "terraformed"
  location = "West Europe"

  tags {
    environment = "training"
    group = "readiness"
  }
}

resource "azurerm_storage_account" "testsa" {
  name                     = "richeney20180323"
  resource_group_name      = "${azurerm_resource_group.testrg.name}"
  location                 = "westeurope"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    environment = "training"
    group = "readiness"
  }
}