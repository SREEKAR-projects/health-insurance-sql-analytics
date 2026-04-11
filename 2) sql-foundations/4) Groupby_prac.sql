select*
from claims_flat;

SELECT member_id, member_name, COUNT(DISTINCT member_id) AS claim_count 
FROM claims_flat 
GROUP BY member_id, member_name
ORDER BY claim_count DESC;

SELECT distinct provider,sum(amount) AS provider_sum
FROM claims_flat 
group by provider
order by provider_sum desc;
