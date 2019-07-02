# Azure Storage

Create storage account in Azure.

## Example Usage

```hcl
resource "azurerm_resource_group" "main" {
  name     = "example-resources"
  location = "westeurope"
}

module "storage" {
  source = "innovationnorway/storage/azurerm"

  name = "example"

  resource_group_name = azurerm_resource_group.main.name

  kind = "FileStorage"

  shares = [
    {
      name  = "example"
      quota = 5120
    }
  ]
}
```

## Arguments

| Name | Type | Description |
| --- | --- | --- |
| `name` | `string` | The name of the storage account. |
| `resource_group_name` | `string` | The name of an existing resource group. |
| `sku` | `string` | The SKU of the storage account. Default: `Standard_RAGRS`. |
| `blobs` | `list` | List of blobs. |
| `containers` | `list` | List of containers. |
| `shares` | `list` | List of shares. |

The `blobs` object accepts the following keys:

| Name | Type | Description |
| --- | --- | --- |
| `name` | `string` | **Required**. The name of the blob. |
| `container_name` | `string` | **Required**. The name of the container. |
| `source_file` | `string` | Path to a local file. |
| `source_uri` | `string` | URI to a remote file. |

The `containers` object must have the following keys:

| Name | Type | Description |
| --- | --- | --- |
| `name` | `string` | The name of the container. |
| `access_type` | `string` | Whether data in the container may be accessed publicly. The options are: `private`, `blob` and `container`. |

The `shares` object must have the following keys:

| Name | Type | Description |
| --- | --- | --- |
| `name` | `string` | The name of the share. |
| `quota` | `string` | The maximum size of the share in GB. |
