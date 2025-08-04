from datetime import datetime, timedelta

import pandas as pd
import psycopg2
import requests
from airflow import DAG
from airflow.models import Variable
from airflow.operators.python import PythonOperator
from sqlalchemy import create_engine

from competitions_to_rds import competitionlist_from_api, write_data_to_rds


# Default arguments for the DAG
default_args = {
    "owner": "Joy",
    "retries": 2,
    "retry_delay": timedelta(minutes=2),
}

# DAG Definition
with DAG(
    dag_id='football_competitions_to_rds',
    default_args=default_args,
    schedule_interval='@daily',
    start_date=datetime(2023, 1, 1),
    catchup=False,
    description='Fetch football competition data and store in RDS',
    tags=['football', 'api', 'rds'],
) as dag:

    fetch_data = PythonOperator(
        task_id='fetch_data',
        python_callable=competitionlist_from_api
    )

    write_data = PythonOperator(
        task_id='write_to_rds',
        python_callable=write_data_to_rds,
        provide_context=True
    )

    # Task flow
    #fetch_data >> write_data
