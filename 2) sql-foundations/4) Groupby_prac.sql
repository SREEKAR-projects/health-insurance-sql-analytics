select*
from claims_flat;

SELECT member_id, member_name, COUNT(DISTINCT member_id) AS claim_count 
FROM claims_flat 
GROUP BY member_id, member_name
ORDER BY claim_count DESC;

SELECT distinct provider,sum(amount) AS provider_sum
FROM claims_flat 
group by provider
order by provider_sum desc;

SELECT city,avg(amount) as avg_amt
FROM claims_flat 
group by city
order by avg_amt desc;

select member_id,
member_name, count(member_id) as cntt, "duplicates" as verdict
FROM claims_flat 
group by  member_id, member_name
having cntt>1;

SELECT provider,avg(amount) as avg_amt
FROM claims_flat 
group by  provider
having avg_amt>100000 ; #reviewfor billing

SELECT provider,avg(amount) as avg_amt
FROM claims_flat 
group by provider
having avg_amt> 1.4*(SELECT avg(amount)
FROM claims_flat ); #review, small idea about suquery however

#p7 ??

select diag_code,count(diag_code) as cnttt
FROM claims_flat 
group by diag_code
order by cnttt desc
limit 2 ;

select diag_code,provider
FROM claims_flat; # explain please


