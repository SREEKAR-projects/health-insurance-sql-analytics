select*
from analysts;

select*
from fraud_cases;

select `name`, salary, (select avg(salary) from analysts)
from analysts
where salary > (select avg(salary) from analysts);

select `name`, salary
from analysts
where salary = (select max(salary) from analysts);

select*
from analysts
where region in (select region from analysts where analyst_id = 102);

select*
from fraud_cases
where amount > (select amount from fraud_cases where case_id = 'C02');

select distinct f.analyst_id, `name`
from analysts as a
join fraud_cases as f
on a.analyst_id = f.analyst_id;

select 
    a.name,
    coalesce(sum(f.amount), 0) as total_amount
from analysts a
left join fraud_cases f
    on a.analyst_id = f.analyst_id
group by a.analyst_id, a.name;

select `name`, salary, (select avg(salary) from analysts), region
from analysts a1
where salary < (select avg(salary) from analysts a2 where a1.region = a2.region);

select `name`, analyst_id from analysts where analyst_id not in 
(select distinct f.analyst_id
from analysts as a
join fraud_cases as f
on a.analyst_id = f.analyst_id);

select *
from fraud_cases
where amount > (
    select avg(amount)
    from fraud_cases
    where status = 'closed'
);


select 
    a.analyst_id,
    a.name,
    count(f.case_id) as open_case_count
from analysts a
join fraud_cases f
    on a.analyst_id = f.analyst_id
where f.status = 'open'
group by a.analyst_id, a.name;


