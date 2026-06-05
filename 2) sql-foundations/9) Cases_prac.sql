select  claim_id,
claim_amount, case when claim_amount < 50000 then "small" when claim_amount between 50000 and 150000 then "medium" else "large" end as claim_size
from claims;

select m.member_name, m.age, case when m.age < 35 then "Young" when m.age between 35 and 55 then "middle" when m.age > 55 then "Senoir" end as age_group, c.claim_amount
from members m
join claims c
on m.member_id = c.member_id;
