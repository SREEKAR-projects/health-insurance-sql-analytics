
SELECT member_id
FROM (select member_id,sum(claim_amount) as total from claims group by member_id) as cl_am
where total > 200000;

With cl_am_cte as
(select member_id,sum(claim_amount) as total 
from claims 
group by member_id)
select member_id 
from cl_am_cte
where total > 200000;

With cl_am_cnt as
(select member_id,count(member_id) as cnt 
from claims 
group by member_id
having cnt >1 ),
mem_city as
(select member_id
from members
where city = 'Hyderabad')
select c.member_id
from cl_am_cnt as c
join mem_city as m
on c.member_id = m.member_id;




