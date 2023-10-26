from datetime import datetime

from dagster import job, op


@op
def write_timestamp():
    with open('log.txt', 'w') as f:
        f.write(datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S'))

@job 
def write_timestamp_job():
    write_timestamp()
