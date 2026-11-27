WITH batch2 AS (

    SELECT *
    FROM {{ source('food_delivery_bronze', 'orders_raw') }}
    WHERE batch_id = 'BATCH_002'

),

cleaned AS (

    SELECT
        TRIM(CAST(order_id AS STRING)) AS order_id,
        TRIM(CAST(customer_id AS STRING)) AS customer_id,
        INITCAP(TRIM(restaurant_name)) AS restaurant_name,
        INITCAP(TRIM(city)) AS city,
        UPPER(TRIM(food_category)) AS food_category,
        TRY_CAST(order_date AS DATE) AS order_date,
        TRY_CAST(quantity AS INT) AS quantity,
        TRY_CAST(item_price AS DECIMAL(10,2)) AS item_price,
        TRY_CAST(delivery_fee AS DECIMAL(10,2)) AS delivery_fee,
        TRY_CAST(discount AS DECIMAL(10,2)) AS discount,
        UPPER(TRIM(order_status)) AS order_status,
        batch_id,
        source_file,
        ingestion_timestamp

    FROM batch2

),

validated AS (

    SELECT
        *,
        CONCAT_WS('; ',

            CASE WHEN order_id IS NULL OR order_id = ''
                THEN 'MISSING_ORDER_ID' END,

            CASE WHEN customer_id IS NULL OR customer_id = ''
                THEN 'MISSING_CUSTOMER_ID' END,

            CASE WHEN restaurant_name IS NULL OR restaurant_name = ''
                THEN 'MISSING_RESTAURANT_NAME' END,

            CASE WHEN city IS NULL OR city = ''
                THEN 'MISSING_CITY' END,

            CASE WHEN food_category IS NULL OR food_category = ''
                THEN 'MISSING_FOOD_CATEGORY' END,

            CASE WHEN order_date IS NULL
                THEN 'INVALID_ORDER_DATE' END,

            CASE WHEN quantity IS NULL OR quantity <= 0
                THEN 'INVALID_QUANTITY' END,

            CASE WHEN item_price IS NULL OR item_price <= 0
                THEN 'INVALID_ITEM_PRICE' END,

            CASE WHEN delivery_fee IS NULL OR delivery_fee < 0
                THEN 'INVALID_DELIVERY_FEE' END,

            CASE WHEN discount IS NULL
                OR discount < 0
                OR discount > (quantity * item_price + delivery_fee)
                THEN 'INVALID_DISCOUNT' END,

            CASE WHEN order_status IS NULL
                OR order_status NOT IN (
                    'DELIVERED',
                    'CANCELLED',
                    'PLACED',
                    'PREPARING',
                    'OUT_FOR_DELIVERY'
                )
                THEN 'INVALID_ORDER_STATUS' END

        ) AS rejection_reason

    FROM cleaned

),

ranked AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY
                CASE WHEN rejection_reason = '' THEN 0 ELSE 1 END,
                ingestion_timestamp ASC,
                SHA2(
                    TO_JSON(STRUCT(
                        customer_id,
                        restaurant_name,
                        city,
                        food_category,
                        order_date,
                        quantity,
                        item_price,
                        delivery_fee,
                        discount,
                        order_status
                    )),
                    256
                ) ASC
        ) AS duplicate_rank

    FROM validated

)

SELECT
    order_id,
    customer_id,
    restaurant_name,
    city,
    food_category,
    order_date,
    quantity,
    item_price,
    delivery_fee,
    discount,
    order_status,
    batch_id,
    source_file,
    ingestion_timestamp,

    CONCAT_WS(
        '; ',
        NULLIF(rejection_reason, ''),
        CASE
            WHEN order_id IS NOT NULL
                 AND order_id != ''
                 AND duplicate_rank > 1
            THEN 'DUPLICATE_ORDER_ID'
        END
    ) AS rejection_reason

FROM ranked