{{ config(
    materialized='table',
    schema='gold'
) }}

WITH date_bounds AS (
    SELECT
        MIN(order_date) AS min_date,
        MAX(order_date) AS max_date
    FROM {{ ref('orders_cleaned_dbt') }}
),

date_spine AS (
    SELECT
        EXPLODE(
            SEQUENCE(min_date, max_date, INTERVAL 1 DAY)
        ) AS order_date
    FROM date_bounds
)

SELECT
    CAST(DATE_FORMAT(order_date, 'yyyyMMdd') AS INT) AS date_sk,
    order_date,
    YEAR(order_date) AS year,
    QUARTER(order_date) AS quarter,
    MONTH(order_date) AS month,
    DATE_FORMAT(order_date, 'MMMM') AS month_name,
    DAY(order_date) AS day,
    DAYOFWEEK(order_date) AS day_of_week,
    DATE_FORMAT(order_date, 'EEEE') AS day_name,
    WEEKOFYEAR(order_date) AS week_of_year,
    CASE
        WHEN DAYOFWEEK(order_date) IN (1, 7) THEN TRUE
        ELSE FALSE
    END AS is_weekend
FROM date_spine