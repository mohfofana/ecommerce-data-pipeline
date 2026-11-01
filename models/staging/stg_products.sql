-- Fixes the "lenght" typos of the source and translates categories to English.
with products as (
    select * from {{ raw_csv('olist_products_dataset') }}
),
translation as (
    select * from {{ raw_csv('product_category_name_translation') }}
)
select
    p.product_id,
    coalesce(p.product_category_name, 'unknown')                       as category_pt,
    coalesce(t.product_category_name_english, p.product_category_name,
             'unknown')                                                as category,
    p.product_name_lenght        as name_length,
    p.product_description_lenght as description_length,
    p.product_photos_qty         as photos_qty,
    p.product_weight_g           as weight_g,
    p.product_length_cm          as length_cm,
    p.product_height_cm          as height_cm,
    p.product_width_cm           as width_cm,
    p.product_length_cm * p.product_height_cm * p.product_width_cm as volume_cm3
from products p
left join translation t using (product_category_name)
