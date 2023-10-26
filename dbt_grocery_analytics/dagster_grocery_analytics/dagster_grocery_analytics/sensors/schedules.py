"""
To add a daily schedule that materializes your dbt assets, uncomment the following lines.
"""

from dagster_dbt import build_schedule_from_dbt_selection
from dagster_grocery_analytics.assets.woolworths.grocery_assets import (
    dbt_grocery_analytics_dbt_assets,
)

schedules = [
#     build_schedule_from_dbt_selection(
#         [dbt_grocery_analytics_dbt_assets],
#         job_name="materialize_dbt_models",
#         cron_schedule="0 0 * * *",
#         dbt_select="fqn:*",
#     ),
]
