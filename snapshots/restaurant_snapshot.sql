
{% snapshot restaurant_snapshot %}

{{
    config(
        target_schema='dbt_work',
        unique_key='restaurant_id',
        strategy='check',
        check_cols=[
            'restaurant_name',
            'restaurant_city',
            'primary_cuisine',
            'service_status'
        ],
        invalidate_hard_deletes=True
    )
}}

SELECT
    restaurant_id,
    restaurant_name,
    restaurant_city,
    primary_cuisine,
    service_status
FROM {{ source('restaurant_source', 'restaurants_current') }}

{% endsnapshot %}
