# 🏦 Banking Modern Data Stack

> **Production-Grade Data Engineering Platform** for real-time banking analytics, processing transactions, customer data, and account balances using a modern, scalable architecture.

[![CI](https://github.com/yassine-fetoui/banking_modern_datastack/actions/workflows/ci.yml/badge.svg)](https://github.com/yassine-fetoui/banking_modern_datastack/actions/workflows/ci.yml)
[![Python 3.11+](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/)
[![dbt](https://img.shields.io/badge/dbt-1.7+-orange.svg)](https://www.getdbt.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🏗️ Architecture Overview

This project implements a robust, end-to-end data pipeline designed for high availability, data quality, and compliance in a banking context.

```mermaid
flowchart LR
    A["PostgreSQL (OLTP)"] 
    -->|"Debezium CDC"| 
    B["Kafka"]

    B 
    -->|"Python Consumer"| 
    C["MinIO<br/>Data Lake (Bronze)"]

    C 
    -->|"Airflow DAGs"| 
    D["Snowflake / PostgreSQL<br/>(Silver)"]

    D 
    -->|"dbt Transformations"| 
    E["Analytics Layer<br/>(Gold)"]

    E 
    --> F["BI Dashboards"]
```

### Key Components
- **Change Data Capture (CDC)**: Debezium captures row-level changes from the core banking PostgreSQL database and streams them to Kafka.
- **Streaming & Ingestion**: Kafka acts as the central nervous system, decoupling source systems from downstream consumers. A Python consumer writes raw events to MinIO (S3-compatible object storage).
- **Orchestration**: Apache Airflow schedules and monitors the batch ingestion from MinIO to the data warehouse and triggers dbt runs.
- **Transformation & Modeling**: dbt (Data Build Tool) handles all SQL transformations, enforcing data quality tests, SCD Type 2 tracking, and generating documentation.

---

## 🧠 Senior Engineering Practices Implemented

### 1. Data Quality & Governance
- **dbt Tests**: Comprehensive schema and data tests (uniqueness, non-null, referential integrity) ensure data reliability before it reaches the Gold layer.
- **PII Masking**: Sensitive customer information (e.g., emails, account numbers) is masked using custom dbt macros (`mask_pii`) to comply with GDPR/CCPA regulations.
- **Audit Trails**: Every transformed table includes `_ingested_at` and `_batch_id` columns for full traceability.

### 2. Slowly Changing Dimensions (SCD Type 2)
Customer and account states are tracked over time using dbt snapshots. This allows the business to query historical states (e.g., "What was the customer's tier when this transaction occurred?").

### 3. CI/CD & Code Quality
- **GitHub Actions**: Automated pipelines run on every Pull Request to enforce code formatting (`black`), linting (`flake8`, `sqlfluff`), and dbt compilation checks.
- **Infrastructure as Code**: The entire local environment is containerized using Docker Compose, ensuring reproducibility across development machines.

### 4. Incident Response & Runbooks
Operational readiness is prioritized with documented runbooks for common failure scenarios (e.g., Kafka consumer lag, dbt test failures). See `docs/runbooks/incident_response.md`.

---

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Python 3.11+
- Make (optional, for convenience)

### 1. Start the Infrastructure
Bring up the entire stack (Postgres, Kafka, Zookeeper, MinIO, Airflow):
```bash
docker-compose up -d
```

### 2. Generate Fake Banking Data
Populate the source PostgreSQL database with realistic banking data:
```bash
python Faker_generator.py --once
```

### 3. Initialize CDC (Debezium)
Register the Debezium connector to start streaming changes to Kafka:
```bash
cd kafka-debezium
python generate_and_post_connector.py
```

### 4. Run dbt Transformations
Execute the dbt models to build the staging and marts layers:
```bash
cd banking_dbt
dbt deps
dbt run
dbt test
```

---

## 📁 Project Structure

```text
banking_modern_datastack/
├── .github/workflows/          # CI/CD pipelines (Linting, dbt tests)
├── banking_dbt/                # dbt project (Models, Macros, Tests, Snapshots)
├── consumer/                   # Kafka to MinIO ingestion scripts
├── data-generator/             # Fake data generation for source DB
├── docker/                     # Airflow DAGs and custom Dockerfiles
├── docs/                       # Architecture diagrams and Runbooks
├── kafka-debezium/             # CDC connector configurations
└── docker-compose.yml          # Local infrastructure definition
```

---

## 👤 Author

**Yassine Fetoui** — Senior Data Engineer  
[GitHub](https://github.com/yassine-fetoui) · [LinkedIn](https://linkedin.com/in/yassine-fetoui)
