-- One row per real customer (customer_unique_id), purchase history summary.
select
    customer_unique_id,
    arg_min(customer_state, purchased_at)        as customer_state,
    arg_min(customer_region, purchased_at)       as customer_region,
    min(purchased_at)                            as first_order_at,
    max(purchased_at)                            as last_order_at,
    count(*)                                     as orders_count,
    sum(payment_value)                           as total_spent,
    avg(payment_value)                           as avg_order_value,
    avg(review_score)                            as avg_review_score,
    avg(case when is_late then 1.0 else 0.0 end) as late_delivery_rate
from {{ ref('fct_orders') }}
where order_status not in ('canceled', 'unavailable')
group by customer_unique_id
