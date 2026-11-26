USE retail;

WITH ref AS (
    SELECT DATE_ADD(MAX(invoice_date), INTERVAL 1 DAY) AS ref_date
    FROM clean_tx
)
SELECT customer_id,
       DATEDIFF((SELECT ref_date FROM ref), MAX(invoice_date)) AS recency,
       COUNT(DISTINCT invoice)                                 AS frequency,
       ROUND(SUM(revenue), 2)                                  AS monetary
FROM clean_tx
GROUP BY customer_id;