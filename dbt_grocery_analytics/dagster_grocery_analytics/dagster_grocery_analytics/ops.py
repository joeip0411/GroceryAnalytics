from datetime import datetime

from dagster import op


@op
def write_timestamp():
    with open('log.txt', 'w') as f:
        f.write(datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S'))
