#revision 

select*
from providers;

select*
from claims;

select*
from members;

select*
from claims_flat;

SELECT claim_id
from claims_flat
where member_id = 'M101' and city = "Hyderabad" and provider like "%Apollo%" and amount = 420000;

select avg(amount)
from claims_flat
where datediff(claim_date,policy_start) < 30
union
select avg(amount)
from claims_flat
where datediff(claim_date,policy_start) > 30;  #in this table claim_amount is amount and less than 30 is potential inception fraud 

select provider,avg(amount)
from claims_flat
group by provider
having avg(amount) >= 1.4*(select avg(amount)
from claims_flat);

SELECT m.member_id,
       m.member_name,
       SUM(c.claim_amount) AS total_filed
FROM members m
JOIN claims c
ON m.member_id = c.member_id
WHERE m.city = 'Hyderabad'
GROUP BY m.member_id, m.member_name
ORDER BY total_filed DESC;


select claim_id
from claims c1
where c1.claim_amount > (SELECT AVG(c2.claim_amount)
    FROM claims c2
    WHERE c1.diagnosis_code = c2.diagnosis_code);
    
    
    SELECT claim_id
FROM claims c1
WHERE c1.claim_amount >
(
   SELECT AVG(c2.claim_amount)
   FROM claims c2
   WHERE c2.diagnosis_code = c1.diagnosis_code
);



select*
from members as m
join claims as c
on m.member_id = c.member_id
order by claim_date desc;

SELECT frm.member_id, frm.claim_date
FROM (
    SELECT c.member_id, c.claim_date, m.policy_start_date
    FROM members AS m
    JOIN claims AS c
    ON m.member_id = c.member_id
) AS frm
WHERE DATEDIFF(frm.claim_date, frm.policy_start_date) < 60;



SELECT t.member_id,
       t.last_claim_date
FROM (
    SELECT c.member_id,
           MAX(c.claim_date) AS last_claim_date,
           m.policy_start_date
    FROM claims c
    JOIN members m
        ON c.member_id = m.member_id
    GROUP BY c.member_id, m.policy_start_date
) t
WHERE DATEDIFF(t.last_claim_date, t.policy_start_date) <= 60;
