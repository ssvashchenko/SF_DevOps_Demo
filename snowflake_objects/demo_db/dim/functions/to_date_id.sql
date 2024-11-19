create or replace function dim.to_date_id (my_date timestamp_ntz)
returns number(38,0)
language sql
as

    (year(date_trunc('day', to_timestamp_ntz(my_date))) * 10000) + 
    (month(date_trunc('day', to_timestamp_ntz(my_date))) * 100) + 
    (day(date_trunc('day', to_timestamp_ntz(my_date))))
  ;