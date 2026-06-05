with latest_claim as (SELECT 
    c.member_id, 
    c.claim_date, 
    c.claim_amount,  
    ROW_NUMBER() OVER(PARTITION BY c.member_id ORDER BY c.claim_date desc ) AS claim_num
from claims AS c)
select*
from latest_claim
where claim_num = 1;

with investi as( SELECT member_id, claim_date,
LAG(claim_date) OVER (PARTITION BY member_id ORDER BY claim_date) AS
prev_claim_date,
DATEDIFF(claim_date,
LAG(claim_date) OVER (PARTITION BY member_id ORDER BY claim_date)
) AS days_gap
FROM claims)
select member_id,claim_date,prev_claim_date,days_gap, "investigation" as statuss
from investi
where days_gap <10;



SELECT m.city,c.member_id,c.claim_amount , dense_rank() over (partition by m.city order by c.claim_amount desc) as ranking
FROM claims as c
join members as m
on c.member_id = m.member_id;


 
SELECT 
    provider_id, 
    claim_date, claim_amount,
    SUM(claim_amount) OVER (PARTITION BY provider_id ORDER BY claim_date) AS rolling_total
FROM claims;

with next_amt as (SELECT member_id, claim_date, claim_amount,
LEAD(claim_amount) OVER (PARTITION BY member_id ORDER BY claim_date) AS next_claim_amount
from claims)
select*
from next_amt
where next_claim_amount >= 2*(claim_amount);

WITH ordered AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY member_id
               ORDER BY claim_date
           ) AS rn,
           COUNT(*) OVER (
               PARTITION BY member_id
           ) AS total_claims
    FROM claims
)






