select distinct upper(trim(city)) as clean_city, COUNT(*) AS count
from members_dirty
group by clean_city;

select distinct city as clean_city, COUNT(*) AS count
from members_dirty
group by clean_city;

SELECT claim_id, member_id, claim_amount
FROM claims_dirty
WHERE claim_amount IS NULL
   OR claim_amount <= 0;
   
   
select member_id, diagnosis_code, claim_amount
from claims_dirty
group by member_id,diagnosis_code, claim_amount
having count(*) > 1