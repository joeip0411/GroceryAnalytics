from dagster import (
    AssetKey,
    EnvVar,
    EventLogEntry,
    RunRequest,
    SensorEvaluationContext,
    asset_sensor,
    multi_asset_sensor,
)
from dagster_grocery_analytics.jobs.ops_job import write_timestamp_job
from dagster_slack import make_slack_on_run_failure_sensor


@asset_sensor(asset_key=AssetKey("my_simple_asset"), job=write_timestamp_job)
def my_asset_sensor(context: SensorEvaluationContext, asset_event: EventLogEntry):
    yield RunRequest()


@multi_asset_sensor(
    monitored_assets = [AssetKey('OBSERVATIONSKUINFO'), 
                        AssetKey('SPECIALSSKU'), 
                        AssetKey('SPECIALSSKUINFO')],
    job = write_timestamp_job,
)
def woolworths_asset_sensor(context):
    asset_events = context.latest_materialization_records_by_key()
    if all(asset_events.values()):
        context.advance_all_cursors()
        return RunRequest()

slack_on_run_failure = make_slack_on_run_failure_sensor(
    channel="#grocery-analytics",
    slack_token=EnvVar("SLACK_TOKEN"),
)




