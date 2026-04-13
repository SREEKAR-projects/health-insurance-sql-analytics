select*
from claims;

select*
from members; #member_name, city, claim_amount, and claim_date

select member_name,city, claim_amount, claim_date
from members as m
INNER JOIN claims as c
on m.member_id = c. member_id;

SELECT m.member_name, c.claim_id, c.claim_amount
FROM members m
LEFT JOIN claims c ON m.member_id = c.member_id;

SELECT m.member_name, m.member_id
FROM members m
LEFT JOIN claims c ON m.member_id = c.member_id
where claim_id is null;

select member_name,city, claim_amount, claim_status
from members as m
INNER JOIN claims as c
on m.member_id = c. member_id
where city = "Hyderabad";

select member_name,city, claim_amount, claim_status
from members as m
INNER JOIN claims as c
on m.member_id = c. member_id
where claim_status = "approved" and claim_amount > 100000 ;

SELECT m.*, c.*
FROM members m
JOIN claims c 
ON m.member_id = c.member_id
WHERE m.member_id = 'M104'; #potential provider fault for issuing duplicate as everything is good from members side

select member_name,city, claim_amount, claim_status, sum(claim_amount) as summ
from members as m
INNER JOIN claims as c
on m.member_id = c. member_id
where city = "Hyderabad"
group by member_name,city, claim_amount, claim_status
order by summ desc; #Ravi kumar filed twice, potential duplicate

SELECT m.member_id, m.member_name,
SUM(c.claim_amount) AS total_filed
FROM members m
JOIN claims c ON m.member_id = c.member_id
WHERE m.city = 'Hyderabad'
GROUP BY m.member_id, m.member_name;

select*
from providers;

select*
from claims;

select pr.provider_id as pr_prov, cl.provider_id as cl_prov, pr.provider_name
from providers as pr
left join claims as cl
on cl.provider_id = pr.provider_id; #all good, AIIMS delhi provider did not ask for a claim 



SELECT pr.provider_id, pr.provider_name
FROM providers pr
LEFT JOIN claims cl
ON pr.provider_id = cl.provider_id
WHERE cl.provider_id IS NULL;

SELECT DISTINCT c.provider_id
FROM claims c
LEFT JOIN providers p
ON c.provider_id = p.provider_id
WHERE p.provider_id IS NULL;

select cl.provider_id as cl_prov, pr.provider_name, sum(claim_amount) as cl_am
from providers as pr
inner join claims as cl
ON cl.provider_id = pr.provider_id
WHERE pr.city = 'Hyderabad'
group by  cl_prov, pr.provider_name
order by cl_am desc;


/*member_id
member_name
total_amount
claim_count*/

select c.member_id,member_name, sum(c.claim_amount ) as total_amount , count(claim_id) as claim_count
from members as m
INNER JOIN claims as c
on m.member_id = c. member_id
WHERE m.city = 'Hyderabad'
group by member_id,member_name
having claim_count > 1
order by total_amount desc;


select  member_name,
m.city,
provider_name,
p.city,
claim_amount
from members as m
INNER JOIN claims as c
on m.member_id = c. member_id
inner join providers as p
ON c.provider_id = p.provider_id
where claim_amount >100000;
