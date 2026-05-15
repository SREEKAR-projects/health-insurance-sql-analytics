#revision 

select*
from providers;

select*
from claims;

SELECT provider_id,
       AVG(claim_amount)
FROM claims
GROUP BY provider_id
HAVING AVG(claim_amount) >
       1.4 * (
           SELECT AVG(claim_amount)
           FROM claims
       );