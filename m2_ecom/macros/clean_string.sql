{% macro clean_string(column_name) %}
    TRIM(UPPER(COALESCE(NULLIF(TRIM({{ column_name }}), ''), 'UNKNOWN')))
{% endmacro %}

