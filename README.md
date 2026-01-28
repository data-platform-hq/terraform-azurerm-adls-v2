# Azure Data Lake Storage Gen2 Terraform module
Terraform module for creation Azure Data Lake Storage Gen2 file system

## Usage
By default, this module will provision Data Lake Gen2 Path in a File System within an Azure Storage Account with custom Bash script, which does not require any Storage specific role. (E.x., Storage Blob Data Contributor/Owner).

If your Service Principal for Terraform is assigned to **"Storage Blob Data Owner"** role it is possible to create File System folders with Azurerm resource(azurerm_storage_data_lake_gen2_path). In this case, please set _**"storage_role_assigned"**_ variable to 'true'.

Below is an example of module usage, here you are providing users in "_adls_ro_users_" and "_adls_rw_users_" variables. After, passing this map to ADLS module.
```hcl
locals {
  # Map with adls2 file systems configuration
  adls2fs = {
    "my-data-lake" = {
      permissions = [
        { group = "********-****-****-****-************", permissions = "rwx", scope = "access", type = "group" },
        { group = "********-****-****-****-************", permissions = "---", scope = "default", type = "group" },
        { group = "********-****-****-****-************", permissions = "rwx", scope = "access", type = "group" },
        { group = "********-****-****-****-************", permissions = "---", scope = "default", type = "group" }
      ]
      folders_config = [
        {
          path: "raw",
          permissions: [
            { group = "********-****-****-****-************", permissions = "r-x", scope = "access", type = "group" },
            { user = "********-****-****-****-************", permissions = "rwx", scope = "access", type = "user" },
            { group = "********-****-****-****-************", permissions = "r-x", scope = "default", type = "group" },
          ]
        },
        {
          path: "e2e",
          permissions: [
            { group = "********-****-****-****-************", permissions = "r-x", scope = "access", type = "group" },
            { user = "********-****-****-****-************", permissions = "rwx", scope = "access", type = "user" },
            { group = "********-****-****-****-************", permissions = "r-x", scope = "default", type = "group" }
          ]
        },
        {
          path: "test",
          permissions: []
        }
      ]
    }
  }
}

module "adls" {
  source   = "data-platform-hq/adls-v2/azurerm"
  for_each = local.adls2fs
  
  name                  = each.key
  permissions           = each.value.permissions
  storage_role_assigned = true 
  folders_config        = each.value.folders_config
  storage_account_id    = module.storage_account.id
  storage_account_name  = module.storage_account.name
  properties            = {
    env = "Development"
  }
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >=3.1.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >=3.1.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_data_lake_gen2_filesystem.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_data_lake_gen2_filesystem) | resource |
| [azurerm_storage_data_lake_gen2_path.other](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_data_lake_gen2_path) | resource |
| [null_resource.create_folders](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ace_default"></a> [ace\_default](#input\_ace\_default) | Default ACE values | `list(map(string))` | <pre>[<br/>  {<br/>    "permissions": "---",<br/>    "scope": "access",<br/>    "type": "other"<br/>  },<br/>  {<br/>    "permissions": "---",<br/>    "scope": "default",<br/>    "type": "other"<br/>  },<br/>  {<br/>    "permissions": "rwx",<br/>    "scope": "access",<br/>    "type": "group"<br/>  },<br/>  {<br/>    "permissions": "rwx",<br/>    "scope": "access",<br/>    "type": "mask"<br/>  },<br/>  {<br/>    "permissions": "rwx",<br/>    "scope": "access",<br/>    "type": "user"<br/>  },<br/>  {<br/>    "permissions": "rwx",<br/>    "scope": "default",<br/>    "type": "group"<br/>  },<br/>  {<br/>    "permissions": "rwx",<br/>    "scope": "default",<br/>    "type": "mask"<br/>  },<br/>  {<br/>    "permissions": "rwx",<br/>    "scope": "default",<br/>    "type": "user"<br/>  }<br/>]</pre> | no |
| <a name="input_folders_config"></a> [folders\_config](#input\_folders\_config) | List of ADLS folders configuration to create | <pre>list(object({<br/>    path        = string<br/>    permissions = any<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of ADLS FS to create | `string` | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | List of ADLS FS permissions | `list(map(string))` | <pre>[<br/>  {}<br/>]</pre> | no |
| <a name="input_properties"></a> [properties](#input\_properties) | Map of properties | `map(string)` | `{}` | no |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | ID of storage account to create ADLS in | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of storage account to create ADLS in | `string` | n/a | yes |
| <a name="input_storage_role_assigned"></a> [storage\_role\_assigned](#input\_storage\_role\_assigned) | Is Storage Blob Data Owner Role assigned to Terraform Service Principal? Provides an ability to create File System with bash script(false) or azurerm resources(true). | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Data Lake Storage Gen2 Filesystem (container ID). |
| <a name="output_name"></a> [name](#output\_name) | The name of the Data Lake Storage Gen2 Filesystem (container name). |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the Storage Account where the Data Lake Storage Gen2 Filesystem exists. |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-azurerm-adls-v2/tree/main/LICENSE)
