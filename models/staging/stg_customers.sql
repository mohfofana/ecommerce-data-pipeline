-- customer_id is unique per order in Olist; customer_unique_id identifies the person.
select
    customer_id,
    customer_unique_id,
    lpad(cast(customer_zip_code_prefix as varchar), 5, '0') as customer_zip_prefix,
    lower(trim(customer_city))                              as customer_city,
    upper(customer_state)                                   as customer_state
from {{ raw_csv('olist_customers_dataset') }}
