import pandas as pd
import requests

url = "http://api.football-data.org/v4/competitions/"

response_API = requests.get(url)

football_data = response_API.json()

football_data['competitions']

competition_names_list = []

for competition in football_data['competitions']:
    name = competition['name']
    competition_names_list.append(name)

distinct_competition_names = set(competition_names_list)

competition_names = list(set(competition_names_list))

# Normalize the 'jobs_list' JSON data into a DataFrame
df = pd.json_normalize(competition_names)
