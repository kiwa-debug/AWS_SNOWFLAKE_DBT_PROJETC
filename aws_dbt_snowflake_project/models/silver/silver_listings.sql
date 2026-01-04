{{config(
    materialized='incremental', 
    unique_key='LISTING_ID'
)}}

select * ,
{{ tag('cast(PRICE_PER_NIGHT as integer)') }} as PRICE_PER_NIGHT_TAG
from {{ ref('bronze_listings') }}
{% if is_incremental() %}
where CREATED_AT > (select COALESCE(max(CREATED_AT), '1900-01-01') from {{ this }}) 
{% endif %}