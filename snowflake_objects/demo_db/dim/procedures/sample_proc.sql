create or replace procedure dim.sample_proc (my_date timestamp_ntz)
returns varchar(16777216)
language sql
as
declare message varchar;
    
    begin    
        message := concat('your date is :', to_varchar(my_date));
        return message;
    end;