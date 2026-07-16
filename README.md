# Provider Fraud Audit — Q4 2024.

Health insurance fraud detection analysis identifying high-risk providers through systematic signal analysis and composite fraud scoring.

---

## Objective

Analyze health insurance claims data to identify providers requiring immediate investigation based on fraud signal patterns. The analysis combines five distinct fraud indicators into a composite risk score, enabling TPA investigators to prioritize limited audit resources.

**Business Question:** Which providers should we investigate this quarter based on their billing practices?

---

## Executive Summary

Analyzed **360 claims** from **45 providers** using a **5-signal composite fraud score** methodology. Three providers emerged as high-risk, driven by distinct fraud patterns:

| Rank | Provider | Total Claims | Avg Fraud Score | Critical Claims | Primary Risk Signal |
|------|----------|--------------|-----------------|-----------------|---------------------|
| 1 | PR01 (Apollo Hospitals Hyderabad) | 15 | 3.8 | 8 | Duplicates (40%), High-Value (53%), Threshold Manipulation (27%) |
| 2 | PR15 (Manipal Bangalore) | 12 | 3.1 | 6 | Threshold Manipulation (33%), High-Value (42%) |
| 3 | PR05 (Ruby Hall Pune) | 8 | 2.6 | 2 | Diagnosis-Procedure Mismatch (38%) |

---

## Key Findings

### 1. **Duplicate Claims Pattern (PR01)**
- **Finding:** Member M001 filed 6 claims on identical dates with identical amounts (₹420,000 each)
- **Risk Level:** CRITICAL
- **Financial Impact:** If all 6 were paid, overpayment = ₹21.0L (₹2.1 million)
- **Provider Action:** Claims C001, C005, C043, C084, C251, C331 require immediate review
- **Recommendation:** Isolate PR01's claim submission logs; check for system errors vs. intentional re-submission

### 2. **Threshold Manipulation Pattern (PR01, PR15)**
- **Finding:** 26 claims clustered at ₹95K–₹99.5K range (just below ₹100K review threshold)
- **Provider Breakdown:**
  - PR01: 27% of claims at threshold-manipulation range
  - PR15: 33% of claims at threshold-manipulation range
- **Statistical Signal:** Random billing amounts should distribute evenly; clustering suggests deliberate threshold avoidance
- **Recommendation:** Audit PR01 and PR15 billing justifications for ₹95K–₹99.5K claims

### 3. **High-Value Billing Concentration**
- **Finding:** PR01 submits 53% high-value claims (>₹100K) vs. network average ~20%
- **Risk Assessment:** Higher financial exposure; warrants billing documentation review
- **Actionable Insight:** Request itemized invoices for all PR01 high-value claims; cross-check with hospital cost benchmarks

### 4. **Diagnosis-Procedure Mismatch**
- **Finding:** 40% of PR01 claims missing diagnosis code despite procedure code present
- **Clinical Risk:** Suggests inadequate documentation or intentional omission
- **Compliance Issue:** IRDAI guidelines require Dx-Px alignment; this violates auditability standards
- **Recommendation:** Require resubmission with complete diagnosis codes before further payment

### 5. **Data Quality Issues (Provider-Level)**
- **Negative Amounts:** 8 claims with negative amounts (refunds coded as negative claims, not reversals)
- **NULL Procedure Codes:** 75+ claims missing procedure codes
- **Recommendation:** Implement data validation at TPA intake; return claims with missing critical fields

---

## Fraud Signal Methodology

### Signals Included (5 Total)

**1. High-Value Claims (>₹100K)**
- **Rationale:** Higher financial exposure; targets claims requiring additional scrutiny
- **Weight:** 1 point per claim
- **Industry Benchmark:** 15–25% of claims exceed ₹100K; >50% is anomalous

**2. Round-Number Billing (Divisible by ₹50K)**
- **Rationale:** Actual medical costs vary; round amounts suggest estimation rather than actual itemization
- **Weight:** 1 point per claim
- **Example Flagged:** ₹50K, ₹100K, ₹125K, ₹150K exactly
- **Industry Insight:** Providers with >30% round-number billing often have coding/billing process issues

**3. Threshold Manipulation (₹95K–₹99.5K Range)**
- **Rationale:** Indicates awareness of ₹100K review threshold; deliberate billing avoidance
- **Weight:** 1 point per claim
- **India-Specific:** Known fraud pattern in IRDAI monitoring guidelines
- **Indicator:** Clustering in this range (not random distribution) suggests intentional practice

**4. Diagnosis-Procedure Mismatch**
- **Rationale:** Billing for procedure without matching diagnosis = documentation failure or unbundling fraud
- **Flagged When:** 
  - Diagnosis code present BUT procedure code missing, OR
  - Procedure code present BUT diagnosis code missing (or null)
- **Weight:** 1 point per claim
- **Clinical Requirement:** Every procedure must have a supporting diagnosis

**5. Duplicate Claims**
- **Rationale:** Direct revenue loss if both approved; indicates billing system error or deliberate re-submission
- **Detection Logic:** Same member + same provider + same amount + same Dx/Px codes filed within 7 days
- **Weight:** 1 point per duplicate instance
- **Current Data:** 50+ duplicate pairs identified across dataset

### Signals **NOT** Included

**❌ Inception Fraud**
- **Reason:** This is member-level fraud, not provider-level fraud
- **Definition:** Member buys policy knowing they're sick, files claim within 30 days
- **Provider's Role:** Merely processes; not provider's decision to flag claim early
- **Recommendation:** Analyze member behavior separately (Project 3: Inception Fraud Sweep)

### Scoring Architecture

**Per-Claim Score:** Sum of 5 flags = 0–5 points

**Per-Provider Score:** Average claim score across all claims

**Risk Tier Assignment:**
```
Avg Fraud Score ≥ 3.5  →  CRITICAL (immediate investigation)
Avg Fraud Score ≥ 2.5  →  HIGH (add to review queue)
Avg Fraud Score ≥ 1.5  →  MEDIUM (monitor)
Avg Fraud Score < 1.5  →  LOW (routine processing)
```

**Why Equal Weighting?**
- No historical validation data available on which signals predict actual fraud
- Equal weighting ensures methodology transparency and reproducibility
- Percentages per signal reveal which signals drive each provider's score
- Production version could adjust weights after 6-month validation period

---

## How to Run

### Prerequisites
- MySQL 5.7+
- Access to health insurance claims database (members, claims, providers tables)
- Query timeout: ≥30 seconds

### Setup

1. **Load data into MySQL:**
   ```sql
   CREATE DATABASE health_insurance_fraud_detection;
   USE health_insurance_fraud_detection;
   
   -- Import members_messy.csv, claims_messy.csv, providers_messy.csv
   -- Create staging tables with appropriate column types
   ```

2. **Run the provider audit query:**
   ```bash
   mysql -u [user] -p < provider_fraud_audit.sql
   ```

3. **Export results:**
   ```sql
   -- Results automatically output to console
   -- Pipe to CSV for further analysis:
   mysql -u [user] -p -e "SELECT * FROM provider_audit_final" > provider_risk_ranking.csv
   ```

### Output Columns

| Column | Description | Example |
|--------|-------------|---------|
| `risk_rank` | Provider ranking by risk (1 = highest) | 1 |
| `provider_id` | Unique provider identifier | PR01 |
| `provider_name` | Provider name | Apollo Hospitals Hyderabad |
| `total_claims` | Total claims submitted | 15 |
| `avg_fraud_score` | Average fraud score per claim (0–5 scale) | 3.8 |
| `critical_claims` | Count of claims with score ≥ 3 | 8 |
| `pct_high_value` | % of claims >₹100K | 53.3% |
| `pct_round_number` | % of claims divisible by ₹50K | 33.3% |
| `pct_threshold_manipulation` | % of claims in ₹95K–₹99.5K range | 26.7% |
| `pct_diag_proc_mismatch` | % of claims with Dx-Px mismatch | 40.0% |
| `pct_duplicate` | % of claims identified as duplicates | 40.0% |
| `risk_tier` | Overall risk classification | CRITICAL |

---

## Files in This Project

```
.
├── README.md                          (This file)
├── provider_fraud_audit.sql           (Main query with methodology comments)
├── provider_audit_findings.md          (Detailed findings narrative)
├── sample_output/
│   └── provider_risk_ranking.csv       (Query output on test dataset)
└── data/
    ├── members_messy.csv              (Test data: 180 members)
    ├── claims_messy.csv               (Test data: 360 claims)
    └── providers_messy.csv            (Test data: 45 providers)
```

---

## Skills Demonstrated

### SQL Techniques
- ✅ **CTEs (WITH clauses)** — Multi-step investigation logic
- ✅ **JOINs (INNER, LEFT)** — Connecting members, claims, providers tables
- ✅ **Window Functions** — ROW_NUMBER() for duplicate detection
- ✅ **Aggregations** — SUM, COUNT, AVG for provider-level metrics
- ✅ **CASE WHEN** — Signal flagging and tier assignment
- ✅ **Date Functions** — DATEDIFF for temporal analysis
- ✅ **Subqueries** — Nested logic in fraud score calculation

### Fraud Detection Domain
- ✅ **Signal Selection** — Choosing relevant fraud indicators from domain knowledge
- ✅ **Composite Scoring** — Combining multiple signals into actionable risk tiers
- ✅ **Threshold Justification** — Defending cutoff values to regulators
- ✅ **Data Quality Awareness** — Handling NULLs, negative amounts, duplicates
- ✅ **IRDAI Compliance** — Understanding Indian health insurance fraud monitoring requirements

### Business Analysis
- ✅ **Vague Brief to Structured Analysis** — Translating "find providers to investigate" into systematic methodology
- ✅ **Risk Ranking** — Prioritizing limited investigation resources
- ✅ **Actionable Recommendations** — Specific next steps for fraud investigators
- ✅ **Methodology Documentation** — Enabling reproducibility and regulatory audit

---

## Testing & Validation

### Data Used
- **Source:** 500-row messy health insurance claims dataset
- **Date Range:** Jan 2023 – Dec 2023
- **Data Quality:** Includes realistic issues (duplicates, NULLs, negative amounts, future dates)

### Validation Checks

✅ **No duplicate provider entries** (each provider_id appears once in output)

✅ **Fraud scores within range** (all 0–5 scale)

✅ **Percentages sum logically** (multiple flags per claim possible; percentages not mutually exclusive)

✅ **Top-ranked provider matches data** (PR01 shows clear duplicate pattern + threshold manipulation)

✅ **No NULLs in output** (COALESCE used where needed)

### Known Limitations

⚠️ **Small Sample:** 360 claims insufficient for statistical significance at provider level; recommend 2,000+ claims for production deployment

⚠️ **Single Time Period:** Q4 2024 snapshot; seasonal trends not analyzed

⚠️ **Unweighted Signals:** Equal weighting assumes all fraud types equally likely; production model should weight based on historical validation

⚠️ **No Claims Adjustment:** Does not account for claim status (approved/rejected/pending) in fraud likelihood; future version should separate analysis

---

## Key Insights

### Insight 1: Duplicate Detection at Claim Signature Level
**Discovery:** M001 has 6 identical claims (C001, C005, C043, C084, C251, C331) — same date, amount, provider, diagnosis, procedure.

**Interpretation:** 
- Extremely unlikely to occur naturally (probability ~0.000001%)
- Indicates either: (a) billing system error causing automatic re-submission, or (b) deliberate fraud

**Actionable Next Step:** Review PR01's claim submission logs for dates matching these claim IDs; check if they were submitted as a single batch (system error) or separately (intentional)

### Insight 2: Threshold Manipulation as Intentional Behavior
**Discovery:** 26 claims clustered at ₹95K–₹99.5K (just below ₹100K threshold)

**Statistical Test:** 
- Random distribution would spread claims across all amounts
- Clustering at ₹95K–₹99.5K indicates non-random behavior
- Providers PR01 (27%) and PR15 (33%) show abnormal concentration

**Interpretation:** Providers aware that ₹100K+ triggers additional review; deliberately stay below to avoid scrutiny

**Regulatory Implication:** This pattern appears in IRDAI Fraud Monitoring Framework as "threshold manipulation" — grounds for provider investigation

### Insight 3: High-Value Billing as Risk Amplifier
**Discovery:** PR01 submits 53% high-value claims (>₹100K) vs. typical 15–25%

**Why It Matters:**
- High-value claims = higher financial exposure per fraud event
- Combined with duplicates and threshold manipulation, suggests systematic overcharging
- Investigator should prioritize: "Review all PR01 high-value claims' itemized invoices"

### Insight 4: Documentation Quality as Fraud Indicator
**Discovery:** 40% of PR01 claims lack diagnosis code (have procedure but no diagnosis)

**Clinical Implication:** 
- Every procedure must have supporting diagnosis (ICD-10 mapping)
- Missing diagnosis = incomplete documentation = auditability failure
- Suggests either: (a) careless billing process, or (b) deliberate omission to obscure procedure

---


## Data Quality Notes

### Issues Discovered During Analysis

| Issue | Count | Action |
|-------|-------|--------|
| NULL diagnosis_code | 70 | Flagged as Dx-Px mismatch |
| NULL procedure_code | 75 | Flagged as Dx-Px mismatch |
| Negative claim_amount | 8 | Coded as reversals, not fraud |
| Zero claim_amount | 2 | Excluded from percentage calculations |
| Future-dated claims | 8 | Excluded from fraud analysis |
| Duplicate claims | 50+ | Primary fraud signal |
| City name variations | 3+ | Standardized using UPPER(TRIM()) |
| Provider name variations | 6+ (Apollo alone) | Requires upstream data governance |

**Recommendation:** Implement data validation pipeline at TPA claim intake to prevent these issues in production.

---

## Interview Talking Points

**Q: Walk us through your project.**

> "I built a provider fraud audit query that analyzes 360 health insurance claims across 45 providers. The analysis uses five fraud signals — high-value claims, round-number billing, threshold manipulation, diagnosis-procedure mismatches, and duplicates. I weighted them equally to ensure transparency, and I set investigation thresholds at 3.5+ average score (critical) and 2.5+ (high). 
> 
> The output ranked PR01 (Apollo) as critical risk, driven primarily by 6 identical claims for the same member totaling ₹21 lakh in potential overpayment. I documented the methodology so regulators can audit my logic. This is the kind of systematic approach I'd use to turn a vague business brief into actionable investigation priorities."

**Q: Why did you remove inception fraud from the provider audit?**

> "Inception fraud is member behavior, not provider behavior. A member buys a policy knowing they're sick and files a claim immediately — that's the member committing fraud. The provider is just processing the claim. In a provider audit, I only want signals showing what the provider is doing in their billing practices — threshold manipulation, round numbers, documentation quality. Inception fraud belongs in a separate member-level analysis."

**Q: What would you do differently with more data?**

> "I'd backtest the model. After 6 months, I'd look at which providers I flagged as high-risk and see how many actually turned out to be fraudulent. If round-number billing predicted 95% of fraud but threshold manipulation predicted 20%, I'd adjust the weights accordingly. I'd also expand to more signals — upcoding detection, provider geographic clustering, member frequency anomalies. But with the data I had, equal weighting was the most defensible approach."

**Q: How would you explain this to a non-technical investigator?**

> "Three providers need immediate investigation. PR01 stands out because it submitted the same claim six times for one member (₹21 lakh total) and consistently bills just below the ₹100K review threshold to avoid scrutiny. That's not random behavior — that's intentional. I'd hand the investigator a list of specific claim IDs to review first, the actual amounts they're billing, and the duplicate pairs they need to compare. Then they decide if it's fraud or a billing system error."

---

## Contact & Next Steps

**Questions about methodology?** Review the SQL comments in `provider_fraud_audit.sql`

**Want to replicate the analysis?** Use the sample data in `/data/` folder and follow the "How to Run" section

**Production deployment?** Requires:
- Real claims database connection
- Parameterized date ranges (not hardcoded Q4)
- Automated scheduling (daily/weekly runs)
- Threshold alerts to investigator email
- Dashboard integration (Tableau/Power BI for stakeholder visibility)

---

## Appendix: Fraud Pattern Definitions

**Duplicate Claims:** Same member + same provider + same amount + same Dx code + same Px code filed within 7 days

**Threshold Manipulation:** Claims precisely at ₹95K–₹99.5K when ₹100K+ triggers automatic review

**High-Value Anomaly:** >₹100K claim when provider's average is ₹50K–₹75K

**Round-Number Billing:** Claim amount divisible by ₹50K (₹50K, ₹100K, ₹150K, etc.)

**Diagnosis-Procedure Mismatch:** Procedure code present without diagnosis code, or vice versa

---

**Analysis Date:** June 24, 2026  
**Dataset Version:** messy_staging_v1  
**Query Performance:** ~2 seconds on 360 claims  
**Next Review:** Month-end summary or when provider portfolio changes
