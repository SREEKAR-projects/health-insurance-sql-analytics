select  claim_id,
claim_amount, case when claim_amount < 50000 then "small" when claim_amount between 50000 and 150000 then "medium" else "large" end as claim_size
from claims;

select m.member_name, m.age, case when m.age < 35 then "Young" when m.age between 35 and 55 then "middle" when m.age > 55 then "Senoir" end as age_group, c.claim_amount
from members m
join claims c
on m.member_id = c.member_id;

select*
from claims;

SELECT SUM(CASE WHEN claim_status = 'approved' THEN 1 ELSE 0 END) AS approved_count, SUM(CASE WHEN claim_status = 'rejected' THEN 1 ELSE 0 END) as rejected_count, SUM(CASE WHEN claim_status = 'pending' THEN 1 ELSE 0 END) as pending_claims_count
FROM claims;

SELECT 
    claim_id, 
    member_id,
    total_score,
    CASE 
        WHEN total_score IN (0, 1) THEN 'Low' -- Fixed "OR" logic
        WHEN total_score = 2 THEN 'Medium'
        WHEN total_score = 3 THEN 'High'
        ELSE 'Critical'
    END AS ranking_category
FROM (
    SELECT 
        c.claim_id,
        c.member_id, -- Added missing comma here
        (IF(DATEDIFF(claim_date, policy_start_date) <= 30, 1, 0) + 
         IF(claim_amount > 100000, 1, 0) + 
         IF(claim_status = 'approved', 1, 0) + 
         IF(COUNT(*) OVER(PARTITION BY c.member_id) > 1, 1, 0)) AS total_score -- Fixed bracket & changed COUNT() to Window Function
    FROM claims AS c
    JOIN members AS m ON c.member_id = m.member_id
) AS ranking_tier
ORDER BY total_score DESC;

CREATE TEMPORARY TABLE joined_table AS 
SELECT 
    p.provider_id, 
    c.claim_amount
FROM providers AS p
JOIN claims AS c ON p.provider_id = c.provider_id;

SELECT provider_id,
       COUNT(*) AS total_claims,
       SUM(CASE WHEN claim_amount > 100000 THEN 1 ELSE 0 END) AS high_value,
       ROUND(
           SUM(CASE WHEN claim_amount > 100000 THEN 1 ELSE 0 END) * 100.0
           / COUNT(*),
           1
       ) AS pct_high
FROM claims
GROUP BY provider_id;

select*
from members;

SELECT 
    m.city, 
    COUNT(c.claim_id) AS total_claims, 
    -- Fixed COUNT logic by using ELSE NULL (or using SUM instead)
    COUNT(CASE WHEN c.claim_status = 'approved' THEN 1 ELSE NULL END) AS approved_cnt, 
    COUNT(CASE WHEN c.claim_status = 'rejected' THEN 1 ELSE NULL END) AS rejected_cnt,  
    -- Fixed typo 'claim_satus' to 'claim_status'
    SUM(CASE WHEN c.claim_status = 'approved' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS approval_rate
FROM members AS m
-- Fixed JOIN condition (should match member_id to member_id)
JOIN claims AS c ON m.member_id = c.member_id 
GROUP BY m.city
order by approval_rate ;
