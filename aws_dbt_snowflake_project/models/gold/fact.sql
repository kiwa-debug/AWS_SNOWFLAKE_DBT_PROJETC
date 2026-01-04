{{ config(materialized='table') }}

-- Optimized fact table that directly selects from OBT
-- No need for ephemeral models since we're just selecting columns
SELECT 
    BOOKING_ID, 
    LISTING_ID, 
    HOST_ID,
    TOTAL_AMOUNT, 
    SERVICE_FEE, 
    CLEANING_FEE, 
    ACCOMMODATES, 
    BEDROOMS, 
    BATHROOMS, 
    PRICE_PER_NIGHT, 
    RESPONSE_RATE,
    PROPERTY_TYPE,
    ROOM_TYPE,
    CITY,
    COUNTRY,
    PRICE_PER_NIGHT_TAG,
    LISTING_CREATED_AT,
    HOST_NAME,
    HOST_SINCE,
    IS_SUPERHOST,
    RESPONSE_RATE_QUALITY,
    HOST_CREATED_AT
FROM
    {{ ref('obt') }}
