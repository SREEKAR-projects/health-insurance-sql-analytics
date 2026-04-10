select*
from claims_flat;

select count(claim_id) as total_claims
from claims_flat;

select sum(amount) as total_billed
from claims_flat;

select ROUND(AVG(amount), 2)
from claims_flat;

select max(amount)
from claims_flat;

SELECT member_name
FROM claims_flat 
ORDER BY amount DESC 
LIMIT 1;

SELECT count(`status`)
FROM claims_flat 
where `status` = "approved";

SELECT count(`status`)
FROM claims_flat 
where `status` = "rejected";

select avg(amount)
FROM claims_flat 
where datediff(claim_date,policy_start) < 30;

select avg(amount)
FROM claims_flat 
where datediff(claim_date,policy_start) > 30; #Inception fraud is taking more amount than others

select sum(amount) as total_claims_paid
from claims_flat
where `status` = "approved";

select sum(amount) as total_billed_grt_thn_100k
from claims_flat
where amount >100000;

select sum(amount) as total_billed
from claims_flat;

#total_billed_grt_thn_100k/total_billed*100.


