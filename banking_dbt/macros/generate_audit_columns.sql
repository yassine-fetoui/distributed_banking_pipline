
{% macro generate_audit_columns() %}
    current_timestamp as _ingested_at,
    invocation_id as _batch_id
{% endmacro %}
