SELECT *
FROM {{ ref('fact_orders_dbt') }}
WHERE item_price <= 0
   OR item_price IS NULL