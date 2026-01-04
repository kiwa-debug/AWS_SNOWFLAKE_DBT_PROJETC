{{ config(materialized='table') }}

SELECT 
    booking.*,
    listings.HOST_ID, 
    listings.PROPERTY_TYPE, 
    listings.ROOM_TYPE, 
    listings.CITY, 
    listings.COUNTRY, 
    listings.ACCOMMODATES, 
    listings.BEDROOMS, 
    listings.BATHROOMS, 
    listings.PRICE_PER_NIGHT, 
    listings.PRICE_PER_NIGHT_TAG, 
    listings.CREATED_AT AS LISTING_CREATED_AT,
    hosts.HOST_NAME, 
    hosts.HOST_SINCE, 
    hosts.IS_SUPERHOST, 
    hosts.RESPONSE_RATE, 
    hosts.RESPONSE_RATE_QUALITY, 
    hosts.CREATED_AT AS HOST_CREATED_AT
FROM
    {{ ref('silver_booking') }} AS booking
    LEFT JOIN {{ ref('silver_listings') }} AS listings
        ON booking.LISTING_ID = listings.LISTING_ID
    LEFT JOIN {{ ref('silver_hosts') }} AS hosts
        ON listings.HOST_ID = hosts.HOST_ID
