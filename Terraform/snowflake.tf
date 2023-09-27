# Database
resource "snowflake_database" "grocery_analytics" {
  name = "GROCERY_ANALYTICS"
  comment = "Database to store grocery related data"
}

# warehouse
resource "snowflake_warehouse" "engineering_wh" {
  name           = "ENGINEERING_WH"
  warehouse_size = "XSMALL"
  auto_resume = true
  auto_suspend  = 1
  max_cluster_count = 1
  warehouse_type = "STANDARD"
  comment = "Warehouse to handle data engineering workload"
}

# schemas
resource "snowflake_schema" "raw" {
  database   = snowflake_database.grocery_analytics.name
  name       = "RAW"
  is_managed = false
}

resource "snowflake_schema" "bronze" {
  database   = snowflake_database.grocery_analytics.name
  name       = "BRONZE"
  is_managed = false
}

resource "snowflake_schema" "silver" {
  database   = snowflake_database.grocery_analytics.name
  name       = "SILVER"
  is_managed = false
}

resource "snowflake_schema" "gold" {
  database   = snowflake_database.grocery_analytics.name
  name       = "GOLD"
  is_managed = false
}

# access roles
resource "snowflake_role" "GA_R" {
  provider = snowflake.security_admin
  name     = "GA_R"
}

resource "snowflake_role" "GA_RW" {
  provider = snowflake.security_admin
  name     = "GA_RW"
}

# grants

## warehouse grants
resource "snowflake_grant_privileges_to_role" "engineering_wh_GA_R" {
  provider   = snowflake.security_admin
  privileges = ["USAGE", "OPERATE", "MONITOR"]
  role_name  = snowflake_role.GA_R.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.engineering_wh.name
  }
}

resource "snowflake_grant_privileges_to_role" "engineering_wh_GA_RW" {
  provider   = snowflake.security_admin
  privileges = ["USAGE", "OPERATE", "MONITOR"]
  role_name  = snowflake_role.GA_RW.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.engineering_wh.name
  }
}

## database grants
#### read
resource "snowflake_grant_privileges_to_role" "db_grocery_analytics_r" {
  provider   = snowflake.security_admin
  privileges = ["USAGE", "MONITOR"]
  role_name  = snowflake_role.GA_R.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.grocery_analytics.name
  }
}

#### read write
resource "snowflake_grant_privileges_to_role" "db_grocery_analytics_rw" {
  provider   = snowflake.security_admin
  role_name = snowflake_role.GA_RW.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.grocery_analytics.name
  }
  all_privileges    = true
  with_grant_option = false
}

## schema grants
#### read
resource "snowflake_grant_privileges_to_role" "grocery_analytics_raw_r" {
  provider   = snowflake.security_admin
  privileges = ["USAGE", "MONITOR"]
  role_name  = snowflake_role.GA_R.name
  on_schema {
    schema_name = "\"${snowflake_database.grocery_analytics.name}\".\"${snowflake_schema.raw.name}\""
  }
}

resource "snowflake_grant_privileges_to_role" "grocery_analytics_bronze_r" {
  provider   = snowflake.security_admin
  privileges = ["USAGE", "MONITOR"]
  role_name  = snowflake_role.GA_R.name
  on_schema {
    schema_name = "\"${snowflake_database.grocery_analytics.name}\".\"${snowflake_schema.bronze.name}\""
  }
}

resource "snowflake_grant_privileges_to_role" "grocery_analytics_silver_r" {
  provider   = snowflake.security_admin
  privileges = ["USAGE", "MONITOR"]
  role_name  = snowflake_role.GA_R.name
  on_schema {
    schema_name = "\"${snowflake_database.grocery_analytics.name}\".\"${snowflake_schema.silver.name}\""
  }
}

resource "snowflake_grant_privileges_to_role" "grocery_analytics_gold_r" {
  provider   = snowflake.security_admin
  privileges = ["USAGE", "MONITOR"]
  role_name  = snowflake_role.GA_R.name
  on_schema {
    schema_name = "\"${snowflake_database.grocery_analytics.name}\".\"${snowflake_schema.gold.name}\""
  }
}

#### read write
resource "snowflake_grant_privileges_to_role" "grocery_analytics_raw_rw" {
  provider   = snowflake.security_admin
  role_name = snowflake_role.GA_RW.name
  on_schema {
    schema_name = "\"${snowflake_database.grocery_analytics.name}\".\"${snowflake_schema.raw.name}\""
  }
  all_privileges    = true
  with_grant_option = false
}

resource "snowflake_grant_privileges_to_role" "grocery_analytics_bronze_rw" {
  provider   = snowflake.security_admin
  role_name = snowflake_role.GA_RW.name
  on_schema {
    schema_name = "\"${snowflake_database.grocery_analytics.name}\".\"${snowflake_schema.bronze.name}\""
  }
  all_privileges    = true
  with_grant_option = false
}

resource "snowflake_grant_privileges_to_role" "grocery_analytics_silver_rw" {
  provider   = snowflake.security_admin
  role_name = snowflake_role.GA_RW.name
  on_schema {
    schema_name = "\"${snowflake_database.grocery_analytics.name}\".\"${snowflake_schema.silver.name}\""
  }
  all_privileges    = true
  with_grant_option = false
}

resource "snowflake_grant_privileges_to_role" "grocery_analytics_gold_rw" {
  provider   = snowflake.security_admin
  role_name = snowflake_role.GA_RW.name
  on_schema {
    schema_name = "\"${snowflake_database.grocery_analytics.name}\".\"${snowflake_schema.gold.name}\""
  }
  all_privileges    = true
  with_grant_option = false
}

## schema objects grant
#### table grants
#### read
resource "snowflake_grant_privileges_to_role" "grocery_analytics_future_table_r" {
  provider   = snowflake.security_admin
  privileges = ["SELECT"]
  role_name  = snowflake_role.GA_R.name
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.grocery_analytics.name
    }
  }
}

#### read write
resource "snowflake_grant_privileges_to_role" "grocery_analytics_future_table_rw" {
  provider   = snowflake.security_admin
  role_name  = snowflake_role.GA_RW.name
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.grocery_analytics.name
    }
  }
  all_privileges = true
}

#### view grants
#### read
resource "snowflake_grant_privileges_to_role" "grocery_analytics_future_view_r" {
  provider   = snowflake.security_admin
  privileges = ["SELECT"]
  role_name  = snowflake_role.GA_R.name
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_database        = snowflake_database.grocery_analytics.name
    }
  }
}

#### read write
resource "snowflake_grant_privileges_to_role" "grocery_analytics_future_view_rw" {
  provider   = snowflake.security_admin
  role_name  = snowflake_role.GA_RW.name
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_database        = snowflake_database.grocery_analytics.name
    }
  }
  all_privileges = true
}

#### sequence grants
#### read
resource "snowflake_grant_privileges_to_role" "grocery_analytics_future_sequence_r" {
  provider   = snowflake.security_admin
  privileges = ["USAGE"]
  role_name  = snowflake_role.GA_R.name
  on_schema_object {
    future {
      object_type_plural = "SEQUENCES"
      in_database        = snowflake_database.grocery_analytics.name
    }
  }
}

#### read write
resource "snowflake_grant_privileges_to_role" "grocery_analytics_future_sequence_rw" {
  provider   = snowflake.security_admin
  role_name  = snowflake_role.GA_RW.name
  on_schema_object {
    future {
      object_type_plural = "SEQUENCES"
      in_database        = snowflake_database.grocery_analytics.name
    }
  }
  all_privileges = true
}

# functional roles
resource "snowflake_role" "Transformer" {
  provider = snowflake.security_admin
  name     = "TRANSFORMER"
}

# access roles to functional roles grants
resource "snowflake_role_grants" "GA_RW_to_Transformer" {
  provider   = snowflake.security_admin
  role_name = snowflake_role.GA_RW.name

  roles = [
    snowflake_role.Transformer.name,
  ]

}

# dbt user creation
resource "snowflake_user" "dbt" {
  provider     = snowflake.security_admin
  name         = "dbt"
  login_name   = "dbt"
  comment      = "service principle for dbt"
  password     = var.SNOWFLAKE_DBT_PASSWORD
  disabled     = false
  display_name = "dbt"
  default_warehouse       = snowflake_warehouse.engineering_wh.name
  default_role            = snowflake_role.Transformer.name
}


resource "snowflake_role_grants" "sysadmin_to_dbt" {
  provider   = snowflake.security_admin
  role_name = "SYSADMIN"

  users = [
    snowflake_user.dbt.name
  ]
}

resource "snowflake_role_grants" "securityadmin_to_dbt" {
  provider   = snowflake.security_admin
  role_name = "SECURITYADMIN"

  users = [
    snowflake_user.dbt.name
  ]
}

