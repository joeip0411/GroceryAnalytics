"""
To add a daily schedule that materializes your dbt assets, uncomment the following lines.
"""
from dagster import ScheduleDefinition
from dagster_dbt import build_schedule_from_dbt_selection

from .assets import dbt_grocery_analytics_dbt_assets
from .jobs import woolworths_assets_job

schedules = [
#     build_schedule_from_dbt_selection(
#         [dbt_grocery_analytics_dbt_assets],
#         job_name="materialize_dbt_models",
#         cron_schedule="0 0 * * *",
#         dbt_select="fqn:*",
#     ),
]
    
woolworths_assets_schedule = ScheduleDefinition(
                    job = woolworths_assets_job,
                    cron_schedule="0 11 * * 6",
)