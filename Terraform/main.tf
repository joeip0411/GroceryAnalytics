terraform {
  required_providers {
    mysql = {
      source = "petoju/mysql"
      version = "3.0.37"
    }
    
    databricks = {
      source = "databricks/databricks"
      version = "1.21.0"
    }

    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.68"
    }

    tls = {
      source = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

provider "mysql" {
  endpoint = "127.0.0.1:3306"
  username = var.dagster_mysql_username
  password = var.dagster_mysql_password
}

provider "azurerm" {
  features {}
  skip_provider_registration = "true"
  subscription_id = var.azure_subscription_id
}

provider "databricks" {
    host = azurerm_databricks_workspace.databricksworkspace.workspace_url
}

provider "snowflake" {
  account = var.SNOWFLAKE_ACCOUNT
  username = var.SNOWFLAKE_USER
  private_key_path = var.SNOWFLAKE_PRIVATE_KEY_PATH

  region = var.SNOWFLAKE_REGION
  role = "SYSADMIN"
}

provider "snowflake" {
  account = var.SNOWFLAKE_ACCOUNT
  username = var.SNOWFLAKE_USER
  private_key_path = var.SNOWFLAKE_PRIVATE_KEY_PATH

  region = var.SNOWFLAKE_REGION
  alias = "security_admin"
  role  = "SECURITYADMIN"
}

provider "tls" {

}