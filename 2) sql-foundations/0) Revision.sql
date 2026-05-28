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
