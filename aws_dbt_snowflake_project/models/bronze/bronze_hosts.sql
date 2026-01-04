{{ config(
    materialized='incremental',
    unique_key='HOST_ID'
) }}

select * from {{ source('staging', 'HOSTS') }}
{% if is_incremental() %}
where CREATED_AT > (select COALESCE(max(CREATED_AT), '1900-01-01') from {{ this }}) 
{% endif %}
