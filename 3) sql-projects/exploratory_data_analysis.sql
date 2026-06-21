select *, row_number() over(partition by member_id,member_name,age,city,gender,policy_start_date,phone) as rankk
from members_messy_staging
order by rankk; #No duplicates in members table

select *, row_number() over(partition by provider_name) as rankk
from providers_messy_staging
order by rankk; #No duplicates in providers table

select*
from providers_messy_staging
where provider_name = 'Ruby hall pune';

select *, row_number() over(partition by claim_id,member_id,provider_id,claim_date,claim_amount,diagnosis_code,procedure_code,claim_status) as rankk
from claims_messy_staging
order by rankk;


select *, row_number() over(partition by member_id) as rankk
from claims_messy_staging
order by rankk desc; #There are multiple claims from single members(i.e member_id)

select *, row_number() over(partition by member_id) as rankk
from claims_messy_staging
where member_id = "M004"; #5 approved claims of same claim amount by provider_id PR04

select *, row_number() over(partition by member_id,provider_id,claim_date,claim_amount,diagnosis_code,procedure_code,claim_status) as rankk
from claims_messy_staging
order by rankk desc;#Only one claim is absolute duplicate

select claim_id, row_number() over(partition by claim_id) as rankk
from claims_messy_staging
order by rankk desc;#Only one claim is absolute duplicate


select*
from claims_messy_staging
where member_id = 'M001'; #2 claims on same day, same amount both approved

select provider_id, count(claim_id) as claim_count
from claims_messy_staging
group by provider_id
order by claim_count desc;

select policy_start_date, str_to_date(policy_start_date,'%Y-%m-%d') cov
from members_messy_staging;

update members_messy_staging
set policy_start_date = str_to_date(policy_start_date,'%Y-%m-%d');

alter table members_messy_staging
modify column policy_start_date date;


select claim_date, str_to_date(claim_date,'%Y-%m-%d') cov
from claims_messy_staging;

update claims_messy_staging
set claim_date = str_to_date(claim_date,'%Y-%m-%d');

alter table claims_messy_staging
modify column claim_date date;