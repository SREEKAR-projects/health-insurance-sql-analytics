CREATE TEMPORARY TABLE mem_claim_join AS
SELECT
    c.claim_id,
    m.member_id,
    m.member_name,
    m.city,m.policy_start_date,
    c.claim_date,
    c.claim_amount,
    c.claim_status
FROM members m
JOIN claims c
ON m.member_id = c.member_id;

select*
from mem_claim_join;

select claim_id, member_id, datediff(claim_date,policy_start_date) as days_since_inception
from mem_claim_join
order by days_since_inception;

WITH incep_risk AS (
    SELECT
        claim_id,
        member_id,
        claim_amount,
        DATEDIFF(claim_date, policy_start_date) AS days_since_inception
    FROM mem_claim_join
)

SELECT
    claim_id,
    member_id,
    claim_amount,
    days_since_inception,
    'Inception Risk' AS flag
FROM incep_risk
WHERE days_since_inception BETWEEN 0 AND 30;

# select year-month, count, and total DATE_FORMAT(claim_date, '%Y-%m')

select distinct claim_amount, count(claim_id) over(Partition by  DATE_FORMAT(claim_date, '%m')) as month_count , sum(claim_amount) OVER (PARTITION BY  DATE_FORMAT(claim_date, '%Y-%m') ) as paritition, month(claim_date), year(claim_date)
from mem_claim_join;

SELECT
    DATE_FORMAT(claim_date, '%Y-%m') AS month,
    COUNT(*) AS claim_count,
    SUM(claim_amount) AS total_billed
FROM claims
GROUP BY DATE_FORMAT(claim_date, '%Y-%m')
ORDER BY month;

with cte_2 as (select claim_id, claim_date, dayofweek(claim_date) as what_day
from claims)
select claim_id, claim_date, dayofweek(claim_date) as what_day, case when what_day = 1 then 1  when what_day = 7  then 1 else 0 end as day_name
from cte_2 
where what_day = 1 or what_day = 7;

select* 
from providers as p 
join claims as c
 on c.provider_id = p.provider_id
 having count(claim_id) > 1 in (select dayofmonth(claim_date) between 25 and 31 from claims);
 
 
SELECT 
    'Approved' AS claim_status_type,
    AVG(DATEDIFF(c.claim_date, m.policy_start_date)) AS avg_days_to_claim
FROM members AS m
INNER JOIN claims AS c ON m.member_id = c.member_id
WHERE c.claim_status = 'approved'

UNION ALL

SELECT 
    'Rejected' AS claim_status_type,
    AVG(DATEDIFF(c.claim_date, m.policy_start_date)) AS avg_days_to_claim
FROM members AS m
INNER JOIN claims AS c ON m.member_id = c.member_id
WHERE c.claim_status = 'rejected';


with q_Cal as (select claim_id, claim_amount,claim_date,  case when month(claim_date) in (4,5,6) then "q1" when month(claim_date) in (7,8,9) then "q2"when month(claim_date) in (10,11,12) then "q3" when month(claim_date) in (1,2,3) then "q4"end as quarters
from claims)
select quarters,count(*),sum(claim_amount), avg(claim_amount)
from q_Cal
group by 
quarters