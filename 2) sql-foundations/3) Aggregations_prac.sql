select*
from claims_flat;

select count(claim_id) as total_claims
from claims_flat;

select sum(amount) as total_billed
from claims_flat;

