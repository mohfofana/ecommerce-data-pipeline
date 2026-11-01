-- Order-level aggregation of items, with the main seller/category
-- (the item with the highest price) and the parcel's physical size.
with items as (
    select
        i.*,
        p.category,
        p.weight_g,
        p.volume_cm3,
        row_number() over (partition by i.order_id order by i.price desc, i.order_item_id) as rank_in_order
    from {{ ref('stg_order_items') }} i
    left join {{ ref('stg_products') }} p using (product_id)
)
select
    order_id,
    count(*)                                                as items_count,
    count(distinct seller_id)                               as sellers_count,
    count(distinct product_id)                              as products_count,
    sum(price)                                              as items_value,
    sum(freight_value)                                      as freight_value,
    sum(weight_g)                                           as total_weight_g,
    sum(volume_cm3)                                         as total_volume_cm3,
    max(case when rank_in_order = 1 then seller_id end)     as main_seller_id,
    max(case when rank_in_order = 1 then category end)      as main_category,
    min(shipping_limit_at)                                  as shipping_limit_at
from items
group by order_id
