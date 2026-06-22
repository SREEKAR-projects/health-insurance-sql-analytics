select *, row_number() over(partition by member_id,member_name,age,city,gender,policy_start_date,phone) as rankk
from members_messy_staging
order by rankk; #No duplicates in members table

select *, row_number() over(partition by provider_name) as rankk
from providers_messy_staging
order by rankk; #No duplicates in providers table

select*
from providers_messy_staging
where provider_name = 'Ruby hall pune';

select *, row_number() over(partition by claim_id,member_id,provider_id,claim_date,claim_amount,diagnosis_code,procedure_code,claim_status) as rankk
from claims_messy_staging
order by rankk;


select *, row_number() over(partition by member_id) as rankk
from claims_messy_staging
order by rankk desc; #There are multiple claims from single members(i.e member_id)

select *, row_number() over(partition by member_id) as rankk
from claims_messy_staging
where member_id = "M004"; #5 approved claims of same claim amount by provider_id PR04

select *, row_number() over(partition by member_id,provider_id,claim_date,claim_amount,diagnosis_code,procedure_code,claim_status) as rankk
from claims_messy_staging
order by rankk desc;#Only one claim is absolute duplicate

select claim_id, row_number() over(partition by claim_id) as rankk
from claims_messy_staging
order by rankk desc;#Only one claim is absolute duplicate


select*
from claims_messy_staging
where member_id = 'M001'; #2 claims on same day, same amount both approved

select provider_id, count(claim_id) as claim_count
from claims_messy_staging
group by provider_id
order by claim_count desc;

select policy_start_date, str_to_date(policy_start_date,'%Y-%m-%d') cov
from members_messy_staging;

update members_messy_staging
set policy_start_date = str_to_date(policy_start_date,'%Y-%m-%d');

alter table members_messy_staging
modify column policy_start_date date;


select claim_date, str_to_date(claim_date,'%Y-%m-%d') cov
from claims_messy_staging;

update claims_messy_staging
set claim_date = str_to_date(claim_date,'%Y-%m-%d');

alter table claims_messy_staging
modify column claim_date date;

select*
from claims_messy_staging;
SELECT *
FROM claims_messy_staging c1
JOIN claims_messy_staging c2
    ON c1.member_id = c2.member_id
   AND ABS(c1.claim_amount) = c2.claim_amount
WHERE c1.claim_amount < 0
  AND c2.claim_amount > 0;
  
  
  
  CREATE VIEW claim_transactions AS
SELECT *,
       CASE
           WHEN claim_amount < 0
           THEN 'REVERSAL'
           ELSE 'CLAIM'
       END AS transaction_type
FROM claims_messy_staging;

select*
from claim_transactions;


SELECT
    provider_id,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN claim_amount < 0 THEN 1 ELSE 0 END) AS reversals,
    ROUND(
        100 * SUM(CASE WHEN claim_amount < 0 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS reversal_rate
FROM claims_messy_staging
GROUP BY provider_id
ORDER BY reversal_rate DESC;

select provider_id,CASE
    WHEN diagnosis_code = ''
         AND procedure_code IS NOT NULL
    THEN 1 WHEN diagnosis_code !=''
         AND procedure_code IS NULL
    THEN 1 ELSE 0
END as billing_suspects
from claims_messy_staging
order by provider_id,billing_suspects desc;

#Different

WITH flags AS (
SELECT
c.provider_id,
c.claim_amount,

-- Flag 1: High value claim
CASE WHEN c.claim_amount > 100000 THEN 1 ELSE 0 END AS high_value_flag,
-- Flag 2: Round number billing
CASE WHEN c.claim_amount % 50000 = 0 THEN 1 ELSE 0 END AS round_number_flag,
-- Flag 3: Billing for procedure without diagnosis
CASE WHEN diagnosis_code = '' AND procedure_code IS NOT NULL THEN 1 WHEN diagnosis_code !='' AND procedure_code IS NULL THEN 1 ELSE 0 END as diag_proc_mismatches,
-- Flag 4: Threshold Manupulation
CASE WHEN claim_amount >= 0.95 * 100000 AND claim_amount < 100000 THEN 1 ELSE 0 END AS threshold_flag,
-- Flag 5: Inflated costs
CASE WHEN claim_amount >= 0.95 * 100000 AND claim_amount < 100000 THEN 1 ELSE 0 END AS inflated_costs

FROM claims_messy_staging c
JOIN members_messy_staging m ON c.member_id = m.member_id

),
scored AS (
SELECT *,
(high_value_flag + round_number_flag) AS fraud_score
FROM flags
)
SELECT *, CASE
WHEN fraud_score >= 3 THEN 'Critical'
WHEN fraud_score = 2 THEN 'High'
WHEN fraud_score = 1 THEN 'Medium'
ELSE 'Low' END AS risk_tier
FROM scored
ORDER BY fraud_score DESC;


