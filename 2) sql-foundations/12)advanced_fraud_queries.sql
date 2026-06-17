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
  order by cntt desc,pct_high_value_claims desc ,pct_round_number_claims desc