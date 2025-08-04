# Data Pipeline: API → RDS → Airbyte → Redshift

This project implements a data pipeline that:

1. **Fetches data from a public API**
2. **Stores it in a PostgreSQL RDS instance using Apache Airflow**
3. **Uses Airbyte to extract the data from RDS**
4. **Loads the data into Amazon Redshift for analytics**

---

##  Project  Steps

- A Python script (used in Airflow) fetches data from a public API.
- Data is processed using `pandas` and saved in structured format.

### 2. RDS Setup  using PostgreSQL
- Amazon RDS PostgreSQL is provisioned as an intermediate using Terraform.
- Tables are created and data is inserted via SQLAlchemy.

### 3.  Airflow DAG
- Airflow orchestrates the pipeline via scheduled DAGs.
- Tasks include:
  - Fetching data from the API
  - Writing data to RDS
- DAGs are containerized using Docker with CeleryExecutor.

### 4. Airbyte Setup
- Airbyte is configured to:
  - Connect to the RDS instance as the **source**
  - Connect to Amazon Redshift as the **destination**
  

