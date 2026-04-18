from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

# =============================================================================
# Default arguments - Best practices for banking / financial workloads
# =============================================================================


# =============================================================================
# DAG Definition
# =============================================================================
with DAG(
    dag_id="dbt_scd2_snapshots_and_marts",
    default_args=default_args,
    description="Daily dbt snapshots (SCD2) + refresh of marts layer - Banking Data Platform",
    schedule_interval="@daily",           # Consider "0 3 * * *" for 3 AM UTC
    start_date=datetime(2025, 9, 1),
    catchup=False,
    tags=["dbt", "scd2", "snapshots", "marts", "banking"],
    max_active_runs=1,                    # Prevent overlapping runs (important for snapshots)
    default_view="graph",
) as dag:

    # ── dbt Snapshot Task (SCD2) ─────────────────────────────────────────────
    dbt_snapshot = BashOperator(
        task_id="dbt_snapshot",
        bash_command="""
            cd /opt/airflow/banking_dbt &&
            dbt snapshot \
                --profiles-dir /home/airflow/.dbt \
                --target {{ var.value.dbt_target | default('prod') }}
        """,
        env={
            "DBT_PROFILES_DIR": "/home/airflow/.dbt",
            "DBT_PROJECT_DIR": "/opt/airflow/banking_dbt"
        },
    )

    # ── dbt Run Marts (after snapshots are updated) ───────────────────────────
    dbt_run_marts = BashOperator(
        task_id="dbt_run_marts",
        bash_command="""
            cd /opt/airflow/banking_dbt &&
            dbt run \
                --select marts \
                --exclude snapshots \
                --profiles-dir /home/airflow/.dbt \
                --target {{ var.value.dbt_target | default('prod') }}
        """,
        env={
            "DBT_PROFILES_DIR": "/home/airflow/.dbt",
            "DBT_PROJECT_DIR": "/opt/airflow/banking_dbt"
        },
    )

    # ── Task Dependencies ─────────────────────────────────────────────────────
    dbt_snapshot >> dbt_run_marts
