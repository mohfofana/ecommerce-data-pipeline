with payments as (
    select
        *,
        row_number() over (partition by order_id order by payment_value desc) as rk
    from {{ ref('stg_payments') }}
)
select
    order_id,
    sum(payment_value)                                 as payment_value,
    max(payment_installments)                          as max_installments,
    count(*)                                           as payments_count,
    max(case when rk = 1 then payment_type end)        as main_payment_type
from payments
group by order_id
