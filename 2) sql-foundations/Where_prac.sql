select*
from claims_flat; # just for reference

select claim_id,member_name,amount
from claims_flat
where `status` = 'approved';

select member_name,provider,amount
from claims_flat
where `status` = 'approved';

select*
from claims_flat
where amount > 100000
order by amount;

SELECT * FROM claims_flat
WHERE `status` IN ('pending', 'rejected');

SELECT * FROM claims_flat
WHERE `status` = 'pending' OR `status` = 'rejected' ;

SELECT * FROM claims_flat
WHERE member_id = 'M101' and provider = 'Apollo Hyd' and amount = '420000' ; #2 rows returned, amount approved twice potential duplicate/fraud

SELECT*, 
       DATEDIFF(claim_date, policy_start) AS gap_days 
FROM claims_flat 
WHERE DATEDIFF(claim_date, policy_start) < 30 and amount > '50000';

select claim_id,member_name,provider,amount
from claims_flat
where provider like '%Apollo%';

SELECT * FROM claims_flat
where age between 50 and 65 and amount > 100000;






