from dagster import AssetSelection, define_asset_job, job

from dagster_grocery_analytics.ops import write_timestamp


@job 
def write_timestamp_job():
    write_timestamp()

#asset materialization jobs
woolworths_assets_job = define_asset_job(
                            "woolworths_asset_job", 
                            selection = AssetSelection.groups('woolworths'),
                        )