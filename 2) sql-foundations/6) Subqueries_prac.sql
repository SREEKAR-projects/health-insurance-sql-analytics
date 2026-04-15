#claim_id, member_id, and claim_amount.

select*
from claims;


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
where total > 200000





