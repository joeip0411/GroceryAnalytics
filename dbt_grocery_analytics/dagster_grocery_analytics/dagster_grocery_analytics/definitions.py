import os

from dagster import (
    Definitions,
    EnvVar,
    load_assets_from_modules,
)
from dagster_dbt import DbtCliResource
from dagster_snowflake_pandas import SnowflakePandasIOManager

from dagster_grocery_analytics.IOManager import (
    LocalCsvIOManager,
    LocalPartitionedCsvIOManager,
    LocalSourceCsvIOManager,
)

from . import assets
from .constants import dbt_project_dir
from .jobs import woolworths_assets_job, write_timestamp_job
from .schedules import schedules, woolworths_assets_schedule
from .sensors import my_asset_sensor, slack_on_run_failure, woolworths_asset_sensor

all_assets = load_assets_from_modules([assets])



#schedules

defs = Definitions(

    assets=all_assets,

    jobs = [
        woolworths_assets_job, 
        write_timestamp_job,
    ],

    schedules = [
            woolworths_assets_schedule,
    ],

    sensors = [
            woolworths_asset_sensor,
            my_asset_sensor,
            slack_on_run_failure,
        ],

    resources={
        "dbt": DbtCliResource(project_dir=os.fspath(dbt_project_dir)),
        'LocalCsvIOManager':LocalCsvIOManager(),
        'LocalSourceCsvIOManager':LocalSourceCsvIOManager(),
        'LocalPartitionedCsvIOManager': LocalPartitionedCsvIOManager(),
        'SnowflakeIOManagerGARaw': SnowflakePandasIOManager(
            account = "xn39852.australia-east.azure",
            user = "dbt",
            password = EnvVar("TF_VAR_SNOWFLAKE_DBT_PASSWORD"),
            database = "GROCERY_ANALYTICS",
            schema = "RAW",
            role = "SYSADMIN",
            warehouse = "ENGINEERING_WH",
        ),
        'SnowflakeIOManagerGABronze': SnowflakePandasIOManager(
            account = "xn39852.australia-east.azure",
            user = "dbt",
            password = EnvVar("TF_VAR_SNOWFLAKE_DBT_PASSWORD"),
            database = "GROCERY_ANALYTICS",
            schema = "BRONZE",
            role = "SYSADMIN",
            warehouse = "ENGINEERING_WH",
        ),
    },
)