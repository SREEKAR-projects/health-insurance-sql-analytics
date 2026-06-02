
SELECT member_id
FROM (select member_id,sum(claim_amount) as total from claims group by member_id) as cl_am
where total > 200000;

With cl_am_cte as
(select member_id,sum(claim_amount) as total 
from claims 
group by member_id)
select member_id 
from cl_am_cte
where total > 200000; #This is more clearer as syntax

With cl_am_cnt as
(select member_id,count(member_id) as cnt 
from claims 
group by member_id
having cnt >1 ),
mem_city as
(select member_id
from members
where city = 'Hyderabad')
select c.member_id
from cl_am_cnt as c
join mem_city as m
on c.member_id = m.member_id;

WITH early_claims AS (
    SELECT c.*,
           DATEDIFF(c.claim_date,m.policy_start_date) AS days_since
    FROM claims c
    JOIN members m
      ON c.member_id = m.member_id
    WHERE DATEDIFF(c.claim_date,m.policy_start_date) <= 30
),
high_value_early AS (
    SELECT *
    FROM early_claims
    WHERE claim_amount > 80000
)
SELECT m.member_name,
       m.city,
       h.claim_amount,
       h.days_since AS days_before_flagged
FROM high_value_early h
JOIN members m
  ON h.member_id = m.member_id;
 

with provider_info as ( select c.provider_id, p.provider_name ,count(c.claim_id) as countt , sum(c.claim_amount) as total_sum, avg(c.claim_amount) as avg_claim 
from claims as c
join providers as p
on c.provider_id = p.provider_id
group by c.provider_id, p.provider_name )
select provider_id,provider_name, case 
when avg_claim > 150000 then "High risk"
else "Normal"
end as risk_param
from provider_info;

WITH provider_info AS (
    SELECT c.provider_id,
           p.provider_name,
           COUNT(c.claim_id) AS total_claims,
           SUM(c.claim_amount) AS total_billed,
           AVG(c.claim_amount) AS avg_claim
    FROM claims c
    JOIN providers p
      ON c.provider_id = p.provider_id
    GROUP BY c.provider_id, p.provider_name
)

SELECT provider_id,
       provider_name,
       total_claims,
       total_billed,
       avg_claim,
       CASE
           WHEN avg_claim > 150000 THEN 'HIGH RISK'
           ELSE 'NORMAL'
       END AS risk_label
FROM provider_info
ORDER BY avg_claim DESC;

with d as
(select member_id,claim_amount, diagnosis_code
from claims)
select*
from d
where count(member_id)>1;

WITH dup_candidates AS (
    SELECT member_id,
           claim_amount,
           diagnosis_code,
           COUNT(*) AS dup_count,
           MIN(claim_date) AS first_date,
           MAX(claim_date) AS last_date
    FROM claims
    GROUP BY member_id, claim_amount, diagnosis_code
    HAVING COUNT(*) > 1
       AND DATEDIFF(MAX(claim_date), MIN(claim_date)) <= 5
)
SELECT c.*
FROM claims c
JOIN dup_candidates dc
  ON c.member_id = dc.member_id
 AND c.claim_amount = dc.claim_amount
 AND c.diagnosis_code = dc.diagnosis_code;