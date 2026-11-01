-- Singular test: an order cannot be delivered before it was purchased.
select order_id, purchased_at, delivered_at
from {{ ref('fct_orders') }}
where delivered_at < purchased_at
