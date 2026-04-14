\# Observations – SQL Foundations (SELECT \& WHERE)



\## 🔍 Observation 1: Duplicate Claim Pattern



\* Member \*\*M101\*\* appears multiple times with identical:



&#x20; \* claim\_date

&#x20; \* provider (Apollo Hyd)

&#x20; \* amount (₹420000)



→ This suggests \*\*potential duplicate billing or repeated claim submission\*\*.

→ Could be:



\* System error

\* Intentional fraud attempt



\---



\## 🔍 Observation 2: High-Value Claims Require Attention



\* Claims above ₹100,000 identified using filtering logic

\* These claims are typically:



&#x20; \* subject to stricter review

&#x20; \* higher financial risk



→ Useful for \*\*prioritizing audit/investigation queues\*\*



\---



\## 🔍 Observation 3: Early Claims (Inception Risk)



\* Claims filed within \*\*30 days of policy start\*\* detected using `DATEDIFF`



→ Early high-value claims may indicate:



\* Pre-existing condition not disclosed

\* Intentional policy purchase before treatment



→ Strong \*\*inception fraud signal\*\*



\---



\## 🔍 Observation 4: Status-Based Segmentation



\* Claims categorized into:



&#x20; \* approved

&#x20; \* pending

&#x20; \* rejected



→ Helps in:



\* Tracking approval rates

\* Identifying unusual rejection patterns

\* Monitoring operational efficiency



\---



\## 🔍 Observation 5: Provider-Level Patterns



\* Claims filtered for providers like \*\*Apollo\*\*



→ Enables:



\* Provider-specific analysis

\* Identification of hospitals with:



&#x20; \* high billing amounts

&#x20; \* frequent claims



\---



\## 🔍 Observation 6: Demographic Risk Segment



\* Members aged \*\*50–65\*\* with high claim amounts identified



→ This segment:



\* Typically has higher medical costs

\* Needs closer monitoring for claim trends



\---



\## 🔍 Observation 7: Full Table Scan Awareness



\* Using `SELECT \*` without filters can lead to:



&#x20; \* performance issues

&#x20; \* unnecessary data load



→ Important to:



\* limit rows (`LIMIT`)

\* select only required columns









