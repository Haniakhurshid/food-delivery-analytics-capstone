SELECT
    'VALID' AS record_type,
    COUNT(*) AS total_records
FROM food_delivery_catalog.dbt_work.batch2_valid

UNION ALL

SELECT
    'REJECTED' AS record_type,
    COUNT(*) AS total_records
FROM food_delivery_catalog.dbt_work.batch2_rejected;