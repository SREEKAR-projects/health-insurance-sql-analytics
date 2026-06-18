WITH flags AS (
    SELECT
        c.claim_id,
        c.member_id,
        c.claim_amount,
        -- Flag 1: Inception risk (claim within 30 days of policy start)
        CASE WHEN DATEDIFF(c.claim_date, m.policy_start_date) <= 30 THEN 1 ELSE 0 END AS inception_flag,
        -- Flag 2: High value claim
        CASE WHEN c.claim_amount > 100000 THEN 1 ELSE 0 END AS high_value_flag,
        -- Flag 3: Round number billing
        CASE WHEN c.claim_amount % 50000 = 0 THEN 1 ELSE 0 END AS round_number_flag,
        -- Flag 4: More than one claim
        CASE WHEN COUNT(*) OVER(PARTITION BY c.member_id) > 1 THEN 1 ELSE 0 END AS more_than_one_claim,
        -- Flag 5: Weekend claims
        CASE WHEN DAYOFWEEK(c.claim_date) IN (1, 7) THEN 1 ELSE 0 END AS weekend_claims
    FROM claims c
    JOIN members m ON c.member_id = m.member_id
),
scored AS (
    SELECT *,
        (inception_flag + high_value_flag + round_number_flag + more_than_one_claim + weekend_claims) AS fraud_score
    FROM flags
)
SELECT *, 
    CASE
        WHEN fraud_score >= 3 THEN 'Critical'
        WHEN fraud_score = 2 THEN 'High'
        WHEN fraud_score = 1 THEN 'Medium'
        ELSE 'Low' 
    END AS risk_tier
FROM scored
ORDER BY fraud_score DESC;


CREATE temporary TABLE flagging
with prov_data as (select p.provider_id,count(c.claim_id) as cntt,sum(c.claim_amount) as total, avg(c.claim_amount) as avg_amt, ROUND(
    SUM(CASE WHEN c.claim_amount > 100000 THEN 1 ELSE 0 END)
    * 100.0
    / COUNT(*),
    2) AS pct_high_value_claims, ROUND(
    SUM(CASE
            WHEN claim_amount % 50000 = 0
            THEN 1
            ELSE 0
        END)
    * 100.0
    / COUNT(*),
    2
) AS pct_round_number_claims
    from providers as p
    join claims as c
    on p.provider_id = c.provider_id
    group by p.provider_id)
    select provider_id,cntt,total,avg_amt,pct_high_value_claims,pct_round_number_claims,case when pct_high_value_claims > 80.00 then "High" when pct_high_value_claims between 30 and 79 then "medium" else "low" end as risk_flag
    from prov_data;

select provider_id,cntt,total,avg_amt,pct_high_value_claims,pct_round_number_claims,risk_flag as risk_flag_1, case when pct_round_number_claims = 100.00 then "high" else "low" end as risk_flag_2
 from flagging
  order by cntt desc,pct_high_value_claims desc ,pct_round_number_claims desc;
  
  
  
  
  
  
  
  -- The IRDAI fraud report requires a list of all suspected duplicate claims from the last financial
-- year. Define a duplicate as: same member_id, same diagnosis_code, same procedure_code,
-- claim_amount within 10% of each other, filed within 7 days of each other. Write the query. For each
-- duplicate pair return both claim_ids, the member_id, the amount difference, and the days gap.


create temporary table d as
select*
from claims;

WITH duplicate_pairs AS (
    SELECT
        a.claim_id AS claim_id_1,
        b.claim_id AS claim_id_2,
        a.member_id,

        a.diagnosis_code,
        a.procedure_code,

        a.claim_amount AS amount_1,
        b.claim_amount AS amount_2,

        ABS(a.claim_amount - b.claim_amount) AS amount_difference,

        ABS(DATEDIFF(a.claim_date, b.claim_date)) AS days_gap

    FROM claims a
    JOIN claims b
        ON a.claim_id < b.claim_id
        AND a.member_id = b.member_id
        AND a.diagnosis_code = b.diagnosis_code
        AND a.procedure_code = b.procedure_code

    WHERE ABS(DATEDIFF(a.claim_date, b.claim_date)) <= 7
      AND ABS(a.claim_amount - b.claim_amount)
          <= 0.10 * LEAST(a.claim_amount, b.claim_amount)
)

SELECT
    claim_id_1,
    claim_id_2,
    member_id,
    amount_difference,
    days_gap
FROM duplicate_pairs
ORDER BY member_id, days_gap, amount_difference;

# member_id, member_name, city, days_since_inception, claim_amount,
#total claims filed, and a rank by days_since_inception ascending

WITH inception_cases AS (
    SELECT
        c.member_id,
        m.member_name,
        m.city,

        DATEDIFF(
            c.claim_date,
            m.policy_start_date
        ) AS days_since_inception,

        c.claim_amount,

        COUNT(*) OVER (
            PARTITION BY c.member_id
        ) AS total_claims

    FROM claims c
    JOIN members m
        ON c.member_id = m.member_id

    WHERE DATEDIFF(
        c.claim_date,
        m.policy_start_date
    ) <= 60
)

SELECT
    member_id,
    member_name,
    city,
    days_since_inception,
    claim_amount,
    total_claims,

    RANK() OVER (
        ORDER BY days_since_inception ASC
    ) AS inception_rank

FROM inception_cases
ORDER BY inception_rank;

create temporary table r1 as
select count(claim_id) as total_claims, sum(case when claim_status = "approved" then 1 else 0 end) as approved_count, sum(case when claim_status = "rejected" then 1 else 0 end) as rejected_count
from claims
where month(claim_date) = 1;

create temporary table r2 as
WITH flags AS (
SELECT
c.claim_id,
c.member_id,
c.claim_amount,
-- Flag 1: Inception risk (claim within 30 days of policy start)
CASE WHEN DATEDIFF(c.claim_date, m.policy_start_date) <= 30
THEN 1 ELSE 0 END AS inception_flag,
-- Flag 2: High value claim
CASE WHEN c.claim_amount > 100000 THEN 1 ELSE 0 END AS high_value_flag,
-- Flag 3: Round number billing
CASE WHEN c.claim_amount % 50000 = 0 THEN 1 ELSE 0 END AS round_number_flag
FROM claims c
JOIN members m ON c.member_id = m.member_id
where month(claim_date) = 1
),
scored AS (
SELECT *,
(inception_flag + high_value_flag + round_number_flag) AS fraud_score
FROM flags
)
SELECT *, CASE
WHEN fraud_score >= 3 THEN 'Critical'
WHEN fraud_score = 2 THEN 'High'
WHEN fraud_score = 1 THEN 'Medium'
ELSE 'Low' END AS risk_tier
FROM scored
ORDER BY fraud_score DESC;

