select claim_id, member_name, amount
from claims_flat;

select member_name, claim_date, `status`
from claims_flat;


select*
from claims_flat;

select count( distinct member_id) as unique_members
from claims_flat;

select distinct city as unique_cities
from claims_flat;

select*
from claims_flat
limit 5; #Full table scan = the database sequentially reading every row (and often every column) in a table instead of using an index to directly locate only the required records.

select member_name, amount as billed_amount
from claims_flat;

select*
from claims_flat
where member_id = 'M101'; #Potential duplicate billing