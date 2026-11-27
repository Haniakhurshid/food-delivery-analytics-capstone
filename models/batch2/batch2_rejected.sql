{{ config(materialized='table') }}

SELECT *
FROM {{ ref('int_batch2_validation') }}
WHERE rejection_reason != ''