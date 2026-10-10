CREATE DATABASE Parch_Posey;
use Parch_Posey;


SELECT id, account_id, occurred_at
FROM orders; 


SELECT occurred_at, account_id, channel
FROM web_events;

SELECT TOP 5
    id,
    account_id,
    total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC;SELECT TOP 5
    id,
    account_id,
    total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC;