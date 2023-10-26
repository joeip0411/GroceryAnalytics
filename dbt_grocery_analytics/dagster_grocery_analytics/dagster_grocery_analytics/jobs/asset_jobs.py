from dagster import AssetSelection, ScheduleDefinition, define_asset_job

#asset materialization jobs
woolworths_assets_job = define_asset_job(
                            "woolworths_asset_job", 
                            selection = AssetSelection.groups('woolworths'),
                        )

woolworths_assets_schedule = ScheduleDefinition(
                    job = woolworths_assets_job,
                    cron_schedule="0 11 * * 6",
)