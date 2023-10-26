import os

from dagster import Definitions, load_assets_from_package_module
from dagster_dbt import DbtCliResource

from .assets import woolworths
from .assets.woolworths.constants import dbt_project_dir
from .jobs.asset_jobs import woolworths_assets_job, woolworths_assets_schedule
from .jobs.ops_job import write_timestamp_job
from .resources.IOManager import (
    LocalCsvIOManager,
    LocalPartitionedCsvIOManager,
    LocalSourceCsvIOManager,
    snowflake_io_manager_ga_bronze,
    snowflake_io_manager_ga_raw,
)
from .sensors.sensors import (
    my_asset_sensor,
    slack_on_run_failure,
    woolworths_asset_sensor,
)

woolworths_assets = load_assets_from_package_module(woolworths, group_name="woolworths")

defs = Definitions(

    assets=woolworths_assets,

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
        'SnowflakeIOManagerGARaw': snowflake_io_manager_ga_raw,
        'SnowflakeIOManagerGABronze': snowflake_io_manager_ga_bronze,
    },
)