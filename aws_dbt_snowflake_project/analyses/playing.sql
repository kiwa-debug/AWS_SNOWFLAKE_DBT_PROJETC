{%set nights_booked = 1%}


select * from {{ ref('bronze_booking') }}
where nights_booked > {{ nights_booked }}