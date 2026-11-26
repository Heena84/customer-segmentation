
USE retail;

CREATE TABLE transactions_dedup AS
SELECT DISTINCT * FROM transactions;

SELECT COUNT(*) FROM transactions_dedup;

-- 1. Indexes (these make later queries faster):
CREATE INDEX idx_dedup_customer ON transactions_dedup (customer_id);
CREATE INDEX idx_dedup_date ON transactions_dedup (invoice_date);

DROP VIEW IF EXISTS clean_tx;

-- 2. Rebuild the clean view on the new table:
CREATE VIEW clean_tx AS
SELECT *, quantity * price AS revenue
FROM transactions_dedup
WHERE customer_id IS NOT NULL
  AND quantity > 0
  AND price > 0
  AND invoice NOT LIKE 'C%';
  
 -- 3. Check the view:
 SELECT COUNT(*) AS rows_clean,
       COUNT(DISTINCT customer_id) AS customers,
       MIN(invoice_date) AS first_date,
       MAX(invoice_date) AS last_date
FROM clean_tx;