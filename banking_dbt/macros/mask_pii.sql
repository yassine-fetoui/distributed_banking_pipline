
{% macro mask_pii(column_name) %}
    CASE 
        WHEN {{ column_name }} IS NULL THEN NULL
        ELSE '****' || RIGHT({{ column_name }}::TEXT, 4)
    END
{% endmacro %}
