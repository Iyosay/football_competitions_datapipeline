import psycopg2
import requests
import pandas as pd
from airflow.models import Variable
from sqlalchemy import create_engine

# Fetch data from API using Airflow Variable
url = Variable.get('url')
response_API = requests.get(url)
football_data = response_API.json()

def competitionlist_from_api():
    """
    Extracts football competition data from API and returns it as a pandas DataFrame.
    """
    football_competitions = []

    for competition in football_data['competitions']:
        area = competition['area']
        competition_list = {
            'id': competition['id'],
            'name': competition['name'],
            'type': competition['type'],
            'numberOfAvailableSeasons': competition['numberOfAvailableSeasons'],
            'area_id': area['id'],
            'area_name': area['name']
        }
        football_competitions.append(competition_list)

    df = pd.DataFrame(football_competitions)
    return df

def write_data_to_rds():
    """
    Writes football competition data to an RDS PostgreSQL database table.
    """
   
    username = Variable.get('USERNAME')
    password = Variable.get('PASSWORD')
    host = Variable.get('HOST')
    port = '5432'
    database = Variable.get('DATABASE_NAME')

    # Create SQLAlchemy engine
    engine = create_engine(f'postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}')

   
    df = competitionlist_from_api()

    # Write to PostgreSQL 
    df.to_sql('football_competitions', con=engine, if_exists='replace', index=False)

    print("Data written to RDS successfully.")
