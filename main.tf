locals {
  folders = length(var.folders) == 0 ? "" : join(",", [for f in var.folders : "${var.root_dir}/${f}"])
  extra_acl = length(var.permissions) == 0 ? "" : format(",%s",
    join(
      ",",
      concat(
        [for v in [for k in var.permissions : k if(contains(keys(k), "user") && k["scope"] == "access")] : "${v.type}:${v.user}:${v.permissions}"],
        [for v in [for k in var.permissions : k if(contains(keys(k), "user") && k["scope"] == "default")] : "default:${v.type}:${v.user}:${v.permissions}"]
      )
    )
  )
}

resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  name               = var.name
  storage_account_id = var.storage_account_id

  lifecycle { prevent_destroy = false }

  dynamic "ace" {
    for_each = length(var.permissions) == 0 ? [] : [for k in var.permissions : k if contains(keys(k), "group")]
    content {
      id          = lookup(var.ad_groups, ace.value["group"], "default")
      permissions = ace.value["permissions"]
      scope       = ace.value["scope"]
      type        = ace.value["type"]
    }
  }
  dynamic "ace" {
    for_each = length(var.permissions) == 0 ? [] : [for k in var.permissions : k if contains(keys(k), "user")]
    content {
      id          = ace.value["user"]
      permissions = ace.value["permissions"]
      scope       = ace.value["scope"]
      type        = ace.value["type"]
    }
  }
  dynamic "ace" {
    for_each = var.ace_default
    content {
      permissions = ace.value["permissions"]
      scope       = ace.value["scope"]
      type        = ace.value["type"]
    }
  }
}

resource "null_resource" "create_root_folder" {
  triggers = {
    build_number = "${timestamp()}${azurerm_storage_data_lake_gen2_filesystem.this.id}"
  }
  provisioner "local-exec" {
    on_failure = continue
    command    = "bash az_create_folders.sh \"${var.storage_account_name}\" \"${azurerm_storage_data_lake_gen2_filesystem.this.name}\" \"${var.root_dir}\" \"${local.extra_acl}\""
  }
}

resource "null_resource" "create_folders" {
  triggers = {
    build_number = "${timestamp()}${azurerm_storage_data_lake_gen2_filesystem.this.id}"
  }
  provisioner "local-exec" {
    on_failure = continue
    command    = "bash az_create_folders.sh \"${var.storage_account_name}\" \"${azurerm_storage_data_lake_gen2_filesystem.this.name}\" \"${local.folders}\" \"${local.extra_acl}\""
  }
  depends_on = [
    null_resource.create_root_folder
  ]
}