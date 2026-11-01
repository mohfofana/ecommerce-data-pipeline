-- One row per order: the central fact table used by the analyses.
-- Delivery KPIs follow the logic of a carrier's service-quality reporting:
-- promised lead time, actual lead time, delay vs promise, late flag.
with orders as (select * from {{ ref('stg_orders') }}),
customers as (select * from {{ ref('stg_customers') }}),
items as (select * from {{ ref('int_order_items_agg') }}),
payments as (select * from {{ ref('int_order_payments_agg') }}),
reviews as (select * from {{ ref('stg_reviews') }}),
sellers as (select * from {{ ref('stg_sellers') }}),
states as (select * from {{ ref('br_states') }})

select
    o.order_id,
    c.customer_unique_id,
    o.order_status,
    o.purchased_at,
    date_trunc('month', o.purchased_at)                       as purchase_month,
    o.approved_at,
    o.shipped_at,
    o.delivered_at,
    o.estimated_delivery_at,

    -- geography
    c.customer_state,
    cs.region                                                 as customer_region,
    s.seller_state,
    ss.region                                                 as seller_region,
    c.customer_state = s.seller_state                         as is_same_state,
    round({{ haversine_km('ss.capital_lat', 'ss.capital_lon', 'cs.capital_lat', 'cs.capital_lon') }}, 0)
                                                              as seller_customer_distance_km,

    -- basket
    i.items_count,
    i.sellers_count,
    i.main_seller_id,
    i.main_category,
    i.items_value,
    i.freight_value,
    i.total_weight_g,
    i.total_volume_cm3,
    p.payment_value,
    p.main_payment_type,
    p.max_installments,

    -- delivery KPIs (days)
    date_diff('day', o.purchased_at, o.estimated_delivery_at)           as promised_days,
    round(date_diff('hour', o.purchased_at, o.approved_at) / 24.0, 2)   as approval_days,
    round(date_diff('hour', o.approved_at, o.shipped_at) / 24.0, 2)     as seller_handling_days,
    round(date_diff('hour', o.shipped_at, o.delivered_at) / 24.0, 2)    as carrier_transit_days,
    round(date_diff('hour', o.purchased_at, o.delivered_at) / 24.0, 2)  as actual_days,
    date_diff('day', o.estimated_delivery_at, o.delivered_at)           as delay_days,
    case
        when o.delivered_at is null then null
        else o.delivered_at::date > o.estimated_delivery_at::date
    end                                                                 as is_late,
    o.shipped_at > i.shipping_limit_at                                  as seller_missed_handover,

    -- customer feedback
    r.review_score,
    r.comment_message is not null                                       as has_review_comment

from orders o
left join customers c  using (customer_id)
left join items i      using (order_id)
left join payments p   using (order_id)
left join reviews r    using (order_id)
left join sellers s    on s.seller_id = i.main_seller_id
left join states cs    on cs.state_code = c.customer_state
left join states ss    on ss.state_code = s.seller_state
