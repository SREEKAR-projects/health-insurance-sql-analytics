WITH claim_flags AS (
  SELECT
    c.claim_id,
    c.member_id,
    c.provider_id,
    c.claim_date,
    c.claim_amount,
    
    -- Flag 1: High-value claim
    CASE WHEN c.claim_amount > 100000 THEN 1 ELSE 0 END AS high_value_flag,
    
    -- Flag 2: Round-number billing
    CASE WHEN c.claim_amount > 0 AND c.claim_amount % 50000 = 0 THEN 1 ELSE 0 END AS round_number_flag,
    
    -- Flag 3: Threshold manipulation
    CASE WHEN c.claim_amount >= 95000 AND c.claim_amount < 100000 THEN 1 ELSE 0 END AS threshold_flag,
    
    -- Flag 4: Diagnosis-Procedure mismatch
    CASE WHEN (c.diagnosis_code = '' OR c.diagnosis_code IS NULL) 
            AND c.procedure_code IS NOT NULL 
         THEN 1 ELSE 0 
    END AS diag_proc_mismatch_flag,
    
    -- Flag 5: Duplicate claim
    CASE WHEN 
      ROW_NUMBER() OVER (
        PARTITION BY c.member_id, c.provider_id, c.claim_amount, c.diagnosis_code, c.procedure_code 
        ORDER BY c.claim_date
      ) > 1 
      THEN 1 ELSE 0 
    END AS duplicate_flag
    
  FROM claims_messy_staging c
  JOIN members_messy_staging m ON c.member_id = m.member_id
),

claim_scores AS (
  SELECT *,
    (high_value_flag + round_number_flag + threshold_flag + diag_proc_mismatch_flag + duplicate_flag) AS claim_fraud_score
  FROM claim_flags
),

provider_risk AS (
  SELECT
    cs.provider_id,
    p.provider_name,
    COUNT(DISTINCT cs.claim_id) AS total_claims,
    
    -- Average fraud score per claim (0-5 scale)
    ROUND(AVG(cs.claim_fraud_score), 2) AS avg_fraud_score,
    
    -- Count of claims with multiple flags (high-risk claims)
    SUM(CASE WHEN cs.claim_fraud_score >= 3 THEN 1 ELSE 0 END) AS critical_claims,
    
    -- PERCENTAGES FOR EACH SIGNAL
    ROUND(100 * SUM(high_value_flag) / COUNT(*), 1) AS pct_high_value,
    ROUND(100 * SUM(round_number_flag) / COUNT(*), 1) AS pct_round_number,
    ROUND(100 * SUM(threshold_flag) / COUNT(*), 1) AS pct_threshold_manipulation,
    ROUND(100 * SUM(diag_proc_mismatch_flag) / COUNT(*), 1) AS pct_diag_proc_mismatch,
    ROUND(100 * SUM(duplicate_flag) / COUNT(*), 1) AS pct_duplicate
    
  FROM claim_scores cs
  JOIN providers_messy_staging p ON cs.provider_id = p.provider_id
  GROUP BY cs.provider_id, p.provider_name
),

final_ranking AS (
  SELECT *,
    CASE 
      WHEN avg_fraud_score >= 3.5 THEN 'CRITICAL'
      WHEN avg_fraud_score >= 2.5 THEN 'HIGH'
      WHEN avg_fraud_score >= 1.5 THEN 'MEDIUM'
      ELSE 'LOW'
    END AS risk_tier,
    
    RANK() OVER (ORDER BY avg_fraud_score DESC) AS risk_rank
    
  FROM provider_risk
)

SELECT 
  risk_rank,
  provider_id,
  provider_name,
  total_claims,
  avg_fraud_score,
  critical_claims,
  pct_high_value,
  pct_round_number,
  pct_threshold_manipulation,
  pct_diag_proc_mismatch,
  pct_duplicate,
  risk_tier
FROM final_ranking
ORDER BY risk_rank ASC;
