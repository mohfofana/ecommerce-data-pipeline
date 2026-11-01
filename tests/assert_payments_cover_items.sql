-- Singular test: for delivered orders, what the customer paid should cover
-- items + freight (tolerance for vouchers / rounding). Flags gross mismatches.
{{ config(severity = 'warn') }}
select order_id, items_value, freight_value, payment_value
from {{ ref('fct_orders') }}
where order_status = 'delivered'
  and payment_value < (items_value + freight_value) * 0.5
