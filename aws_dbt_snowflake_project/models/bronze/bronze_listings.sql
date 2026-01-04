{{ config(
    materialized='incremental',
    unique_key='LISTING_ID'
) }}

select * from {{ source('staging', 'LISTINGS') }}
{% if is_incremental() %}
where CREATED_AT > (select COALESCE(max(CREATED_AT), '1900-01-01') from {{ this }}) 
{% endif %}