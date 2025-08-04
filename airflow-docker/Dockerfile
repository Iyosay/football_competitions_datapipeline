FROM apache/airflow:2.8.1

WORKDIR /app

COPY requirements.txt .   # Copy requirements.txt separately first (before COPY . .)
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
