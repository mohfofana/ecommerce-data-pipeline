-- A few orders have several reviews: keep the most recent answer per order.
with ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by review_answer_timestamp desc, review_creation_date desc
        ) as rn
    from {{ raw_csv('olist_order_reviews_dataset') }}
)
select
    review_id,
    order_id,
    review_score,
    review_comment_title    as comment_title,
    review_comment_message  as comment_message,
    review_creation_date    as created_at,
    review_answer_timestamp as answered_at
from ranked
where rn = 1
