SELECT *
FROM {{ ref('fact_orders_dbt') }}
WHERE quantity <= 0
   OR quantity IS NULL