variable "azure_subscription_id" {
  type = string
}

variable "key_permissions" {
  type        = list(string)
  description = "List of key permissions."
  default     = ["List", "Create", "Delete", "Get", "Purge", "Recover", "Update", "GetRotationPolicy", "SetRotationPolicy"]
}

variable "secret_permissions" {
  type        = list(string)
  description = "List of secret permissions."
  default     = ["Get", "List", "Set", "Delete"]
}

variable "dagster_mysql_username" {
  type = string
}

variable "dagster_mysql_password" {
  type = string
}

variable "SNOWFLAKE_USER" {
    type = string
}

variable "SNOWFLAKE_ACCOUNT" {
    type = string
}

variable "SNOWFLAKE_PRIVATE_KEY_PATH" {
    type = string
}

variable "SNOWFLAKE_REGION" {
    type = string
}

variable "SNOWFLAKE_DBT_PASSWORD" {
  type = string
}