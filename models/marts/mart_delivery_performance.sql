-- Monthly service-quality dashboard by customer state.
select
    purchase_month,
    customer_state,
    customer_region,
    count(*)                                         as delivered_orders,
    avg(case when is_late then 1.0 else 0.0 end)     as late_rate,
    avg(promised_days)                               as avg_promised_days,
    avg(actual_days)                                 as avg_actual_days,
    avg(case when is_late then delay_days end)       as avg_delay_days_when_late,
    avg(freight_value)                               as avg_freight_value,
    avg(review_score)                                as avg_review_score
from {{ ref('fct_orders') }}
where order_status = 'delivered'
  and delivered_at is not null
group by 1, 2, 3
