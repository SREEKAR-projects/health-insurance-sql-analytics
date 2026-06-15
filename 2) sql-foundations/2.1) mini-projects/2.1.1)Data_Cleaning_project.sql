select distinct upper(trim(city)) as clean_city, COUNT(*) AS count
from members_dirty
group by clean_city;

select distinct city as clean_city, COUNT(*) AS count
from members_dirty
group by clean_city;

SELECT claim_id, member_id, claim_amount
FROM claims_dirty
WHERE claim_amount IS NULL
   OR claim_amount <= 0;
   
   
select member_id, diagnosis_code, claim_amount
from claims_dirty
group by member_id,diagnosis_code, claim_amount
having count(*) > 1;


select claim_id, (select count(claim_id) from claims)
from claims
limit 1;

select count(claim_id) as no_of_rows,( select count(claim_id)
FROM claims_dirty
WHERE claim_amount IS NULL) as null_claim_amounts, ( select count(claim_id)
FROM claims_dirty
WHERE diagnosis_code IS NULL) as null_diagnosis_code, ( select count(claim_id)
FROM claims_dirty
WHERE provider_id IS NULL) as null_provider_id, ( select count(claim_id)
FROM claims_dirty
WHERE claim_amount <= 0 ) as invalid_amounts, ( select count(claim_id)
FROM claims_dirty
WHERE claim_date > current_date() ) as future_dated_claims
from claims_dirty;

select p.provider_id, p.provider_name, count(claim_id)
from providers as p
join claims as c
on p.provider_id = c.provider_id
where provider_name like trim("%Apollo%")
group by p.provider_id, p.provider_name;

select*
from claims_dirty;

select*
from providers;

select*
from members_dirty;

select m.member_id
from claims_dirty as c
join members_dirty as m
on c.member_id = m.member_id
join providers as p
on p.provider_id = c.provider_id
where m.city != p.city;


CREATE TEMPORARY TABLE dup_mem_id_counts AS 
SELECT c.member_id, COUNT(*) AS duplicates
from members_dirty as m
join claims_dirty as c
    ON c.member_id = m.member_id
GROUP BY c.member_id
HAVING COUNT(*) > 1;

select count(member_id) as wrong_dates, (select count(member_id)
from dup_mem_id_counts) as duplicate_mem_ids, 
(select sum(case when m.age <0 or m.age > 120 then 1 else 0 end) 
from members_dirty as m
join claims_dirty as c
on c.member_id = m.member_id) as age_error
from members_dirty
where policy_start_date > current_date() ;


SELECT
(
    SELECT COUNT(*)
    FROM members_dirty
    WHERE policy_start_date > CURDATE()
) AS future_policy_dates,

(
    SELECT COUNT(*)
    FROM dup_mem_id_counts
) AS duplicate_mem_ids,

(
    SELECT SUM(
        CASE
            WHEN age < 0 OR age > 120
            THEN 1
            ELSE 0
        END
    )
    FROM members_dirty
) AS age_error;


SELECT
COUNT(*) AS total,
SUM(CASE WHEN member_id IS NULL THEN 1 ELSE 0 END) AS null_ids,
SUM(CASE WHEN age < 0 OR age > 120 THEN 1 ELSE 0 END) AS invalid_age,
SUM(CASE WHEN policy_start_date > CURDATE() THEN 1 ELSE 0 END) AS future_policy,
(SELECT COUNT(*) - COUNT(DISTINCT member_id) FROM members) AS duplicate_ids
FROM members;