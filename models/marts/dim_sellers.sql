-- Seller scorecard: volume, revenue, punctuality and satisfaction.
with items as (
    select i.seller_id, i.order_id, i.price, i.freight_value
    from {{ ref('stg_order_items') }} i
),
orders as (select * from {{ ref('fct_orders') }} where order_status = 'delivered')
select
    s.seller_id,
    s.seller_state,
    s.seller_city,
    count(distinct i.order_id)                              as orders_count,
    sum(i.price)                                            as revenue,
    avg(case when o.is_late then 1.0 else 0.0 end)          as late_rate,
    avg(case when o.seller_missed_handover then 1.0 else 0.0 end) as missed_handover_rate,
    avg(o.seller_handling_days)                             as avg_handling_days,
    avg(o.review_score)                                     as avg_review_score
from {{ ref('stg_sellers') }} s
join items i using (seller_id)
join orders o using (order_id)
group by 1, 2, 3
