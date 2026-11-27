-- depends_on: {{ ref('batch2_valid') }}
{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='order_id',
        schema='silver'
    )
}}

{% if is_incremental() %}

SELECT
    order_id,
    CAST(order_date AS DATE) AS order_date,
    customer_id,
    restaurant_name,
    city,
    food_category,
    CAST(quantity AS INT) AS quantity,
    CAST(item_price AS DECIMAL(10,2)) AS item_price,
    CAST(delivery_fee AS DECIMAL(10,2)) AS delivery_fee,
    CAST(discount AS DECIMAL(10,2)) AS discount,
    order_status,
    batch_id,
    source_file,
    ingestion_timestamp,
    CAST(
        quantity * item_price + delivery_fee - discount
        AS DECIMAL(12,2)
    ) AS order_amount
FROM {{ ref('batch2_valid') }}

{% else %}

SELECT
    order_id,
    order_date,
    customer_id,
    restaurant_name,
    city,
    food_category,
    quantity,
    item_price,
    delivery_fee,
    discount,
    order_status,
    batch_id,
    source_file,
    ingestion_timestamp,
    order_amount
FROM {{ source('food_delivery_silver', 'orders_cleaned') }}

{% endif %}