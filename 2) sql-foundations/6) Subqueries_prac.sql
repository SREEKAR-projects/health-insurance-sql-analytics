#claim_id, member_id, and claim_amount.

select*
from claims;

select*
from members;



select claim_id, member_id,claim_amount, (select avg(claim_amount) from claims) as av_cl
from claims
where claim_amount > (select avg(claim_amount) from claims); #av_cl is not neccesary but for my reference 


# member_id and member_name



SELECT member_id, member_name FROM members
WHERE member_id IN (SELECT member_id FROM claims WHERE claim_amount > 100000);

select claim_id, member_id,claim_amount, (select avg(claim_amount) from claims) as av_cl
from claims
where claim_amount > (select avg(claim_amount) from claims);

select diagnosis_code, claim_amount
from claims c1
where claim_amount > ( select avg(claim_amount)
from claims c2
where c1.diagnosis_code = c2.diagnosis_code);


SELECT member_id
FROM (select member_id,sum(claim_amount) as total from claims group by member_id) as cl_am
where total > 200000;


select member_id
from claims
where member_id not in (select member_id from members);

select m.member_id
from members as m
left join claims as c
on c.member_id = m.member_id
where m.member_id is null; #subquery is safer as filtering happens



select*
from providers;


select*
from (select p.provider_id, p.provider_name, c.claim_date, sum(c.claim_amount) as pr_cl
from providers as p
join claims as c
on p.provider_id = c.provider_id
where claim_date like "2024-04%" 
group by p.provider_id, p.provider_name, c.claim_date) as pr_spl
where pr_cl > (select avg(claim_amount) from claims where claim_date like "2024-04%")













