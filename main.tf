locals {
  blobs = [
    for b in var.blobs : merge({
      type         = "block"
      size         = 0
      content_type = "application/octet-stream"
      source_file  = null
      source_uri   = null
      attempts     = 1
      metadata     = {}
    }, b)
  ]

  containers = [
    for c in var.containers : merge({
      access_type = "private"
    }, c)
  ]

  shares = [
    for s in var.shares : merge({
      quota = 5120
    }, s)
  ]
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_storage_account" "main" {
  name                      = var.name
  resource_group_name       = data.azurerm_resource_group.main.name
  location                  = coalesce(var.location, data.azurerm_resource_group.main.location)
  account_kind              = var.kind
  account_tier              = split("_", var.sku)[0]
  account_replication_type  = split("_", var.sku)[1]
  access_tier               = var.access_tier
  enable_blob_encryption    = true
  enable_file_encryption    = true
  enable_https_traffic_only = var.https_only

  identity {
    type = var.assign_identity ? "SystemAssigned" : null
  }
}

resource "azurerm_storage_container" "main" {
  count                 = length(local.containers)
  name                  = local.containers[count.index].name
  resource_group_name   = data.azurerm_resource_group.main.name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = local.containers[count.index].access_type
}

resource "azurerm_storage_queue" "main" {
  count                = length(var.queues)
  name                 = var.queues[count.index]
  resource_group_name  = data.azurerm_resource_group.main.name
  storage_account_name = azurerm_storage_account.main.name
}

resource "azurerm_storage_share" "main" {
  count                = length(local.shares)
  name                 = local.shares[count.index].name
  resource_group_name  = data.azurerm_resource_group.main.name
  storage_account_name = azurerm_storage_account.main.name
  quota                = local.shares[count.index].quota
}

resource "azurerm_storage_table" "main" {
  count                = length(var.tables)
  name                 = var.tables[count.index]
  resource_group_name  = data.azurerm_resource_group.main.name
  storage_account_name = azurerm_storage_account.main.name
}

resource "azurerm_storage_blob" "main" {
  count                  = length(local.blobs)
  name                   = local.blobs[count.index].name
  resource_group_name    = data.azurerm_resource_group.main.name
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = local.blobs[count.index].container_name
  type                   = local.blobs[count.index].type
  size                   = local.blobs[count.index].size
  content_type           = local.blobs[count.index].content_type
  source                 = local.blobs[count.index].source_file
  source_uri             = local.blobs[count.index].source_uri
  attempts               = local.blobs[count.index].attempts
  metadata               = local.blobs[count.index].metadata
  depends_on             = [azurerm_storage_container.main]
}
