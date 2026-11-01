-- Reads a raw Olist extract (gzip CSV) straight from disk with DuckDB.
{% macro raw_csv(name) -%}
    read_csv_auto('{{ var("raw_path") }}/{{ name }}.csv.gz', header = true)
{%- endmacro %}
