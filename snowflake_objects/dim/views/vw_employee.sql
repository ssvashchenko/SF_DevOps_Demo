create or replace view dim.vw_employee 
as
select 
	d_employee_id,
	employee_id,
	first_name,
	last_name,
	middle_name,
	user_name,
	email_address,
	job_code,
	job_title,
	company_code,
	company,
	location_code,
	location,
   	supervisor_employee_id,
	supervisor_name,
	create_date,
	created_by,
	update_date,
	'svashchenko' as updated_by
from dim.d_employee;