-- RFM base: recency measured against the last purchase date in the dataset.
with ref_date as (
    select max(last_order_at) + interval 1 day as as_of from {{ ref('dim_customers') }}
),
base as (
    select
        c.customer_unique_id,
        c.customer_state,
        c.customer_region,
        date_diff('day', c.last_order_at, r.as_of) as recency_days,
        c.orders_count                             as frequency,
        c.total_spent                              as monetary,
        c.avg_review_score,
        c.late_delivery_rate
    from {{ ref('dim_customers') }} c
    cross join ref_date r
    where c.total_spent is not null
)
select
    *,
    -- customer_unique_id breaks ties so that scores are reproducible from run to run
    6 - ntile(5) over (order by recency_days, customer_unique_id) as r_score,
    case when frequency >= 3 then 5 when frequency = 2 then 4 else 1 end as f_score,
    ntile(5) over (order by monetary, customer_unique_id)         as m_score
from base
