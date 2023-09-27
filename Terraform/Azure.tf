resource "azurerm_resource_group" "GroceryAnalytics" {
  name     = "GroceryAnalytics"
  location = "Australia Southeast"

}

resource "azurerm_storage_account" "datalake" {
  name                     = "joeipdataengineering"
  resource_group_name      = azurerm_resource_group.GroceryAnalytics.name
  location                 = azurerm_resource_group.GroceryAnalytics.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  is_hns_enabled = true
  depends_on = [
    azurerm_resource_group.GroceryAnalytics
  ]
}

resource "azurerm_storage_container" "groceryanalytics" {
  name                  = "groceryanalytics"
  storage_account_name  = azurerm_storage_account.datalake.name
  container_access_type = "private"
  depends_on = [
    azurerm_storage_account.datalake
  ]
}

resource "azurerm_databricks_workspace" "databricksworkspace" {
  name                = "joeip_databricks"
  resource_group_name = azurerm_resource_group.GroceryAnalytics.name
  location            = azurerm_resource_group.GroceryAnalytics.location
  sku                 = "standard"
  depends_on = [
    azurerm_resource_group.GroceryAnalytics
  ]
}

data "databricks_node_type" "smallest" {
  local_disk = true
  category = "Compute Optimized"
  depends_on = [
   azurerm_databricks_workspace.databricksworkspace
  ]
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
    depends_on = [
     azurerm_databricks_workspace.databricksworkspace
  ]
}

resource "databricks_cluster" "single_node" {
  cluster_name            = "Single Node"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 15

  spark_conf = {
    # Single-node
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }

  custom_tags = {
    "ResourceClass" = "SingleNode"
  }
}


resource "azurerm_key_vault" "vault" {
  name                        = "joeipdataengineering"
  resource_group_name         = azurerm_resource_group.GroceryAnalytics.name
  location                    = azurerm_resource_group.GroceryAnalytics.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  access_policy {

    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = local.current_user_id
    key_permissions    = var.key_permissions
    secret_permissions = var.secret_permissions

  }
  depends_on = [
    azurerm_resource_group.GroceryAnalytics
  ]
}

/*
Data sources provide a way to fetch information from various external systems or services 
and use that information within your Terraform configuration.
*/
data "azurerm_client_config" "current" {}

/*
 Define named values that can be reused within your configuration. 
 These values are calculated once during the configuration's planning phase 
 and can be used in various parts of your configuration,
*/
locals {
  current_user_id = data.azurerm_client_config.current.object_id
}