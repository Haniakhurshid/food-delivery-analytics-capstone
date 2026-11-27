{{ config(
    materialized='table',
    schema='gold'
) }}

SELECT
    s.order_id,

    d.date_sk,
    r.restaurant_sk,
    c.city_sk,
    fc.food_category_sk,

    s.customer_id,
    s.quantity,
    s.item_price,
    s.delivery_fee,
    s.discount,
    s.order_amount,
    s.order_status,
    s.batch_id,
    s.source_file,
    s.ingestion_timestamp

FROM {{ ref('orders_cleaned_dbt') }} s

LEFT JOIN {{ source('food_delivery_gold', 'dim_restaurant') }} r
    ON s.restaurant_name = r.restaurant_name
    AND s.order_date BETWEEN r.valid_from AND r.valid_to

LEFT JOIN {{ source('food_delivery_gold', 'dim_city') }} c
    ON s.city = c.city_name

LEFT JOIN {{ source('food_delivery_gold', 'dim_food_category') }} fc
    ON s.food_category = fc.category_name

LEFT JOIN {{ ref('dim_date_dbt') }} d
    ON s.order_date = d.order_date