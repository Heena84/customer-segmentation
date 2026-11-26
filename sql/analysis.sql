USE retail;

-- 1. Monthly revenue trend
SELECT DATE_FORMAT(invoice_date, '%Y-%m') AS month,
       ROUND(SUM(revenue), 2) AS revenue
FROM clean_tx
GROUP BY month
ORDER BY month;

-- 2. Month-over-month growth (LAG)
WITH m AS (
    SELECT DATE_FORMAT(invoice_date, '%Y-%m') AS ym, SUM(revenue) AS rev
    FROM clean_tx
    GROUP BY ym
)
SELECT ym, ROUND(rev, 2) AS revenue,
       ROUND((rev - LAG(rev) OVER (ORDER BY ym))
             / LAG(rev) OVER (ORDER BY ym) * 100, 1) AS mom_growth_pct
FROM m;

-- 3. Running total of revenue (SUM OVER)
WITH m AS (
    SELECT DATE_FORMAT(invoice_date, '%Y-%m') AS ym, SUM(revenue) AS rev
    FROM clean_tx
    GROUP BY ym
)
SELECT ym, ROUND(rev, 2) AS revenue,
       ROUND(SUM(rev) OVER (ORDER BY ym), 2) AS cumulative_revenue
FROM m;

-- 4. Top 10 countries by revenue
SELECT country, ROUND(SUM(revenue), 2) AS revenue
FROM clean_tx
GROUP BY country
ORDER BY revenue DESC
LIMIT 10;

-- 5. Top 10 products by revenue
SELECT stock_code, description, ROUND(SUM(revenue), 2) AS revenue
FROM clean_tx
GROUP BY stock_code, description
ORDER BY revenue DESC
LIMIT 10;

-- 6. Average order value
SELECT ROUND(SUM(revenue) / COUNT(DISTINCT invoice), 2) AS avg_order_value
FROM clean_tx;

-- 7. Repeat purchase rate
SELECT ROUND(100 * SUM(orders > 1) / COUNT(*), 1) AS repeat_customer_pct
FROM (
    SELECT customer_id, COUNT(DISTINCT invoice) AS orders
    FROM clean_tx
    GROUP BY customer_id
) t;

-- 8. Top 10 customers with RANK
SELECT customer_id, ROUND(SUM(revenue), 2) AS revenue,
       RANK() OVER (ORDER BY SUM(revenue) DESC) AS revenue_rank
FROM clean_tx
GROUP BY customer_id
ORDER BY revenue_rank
LIMIT 10;

-- 9. Best-selling product in each country (RANK + PARTITION BY)
WITH p AS (
    SELECT country, description, SUM(revenue) AS rev
    FROM clean_tx
    GROUP BY country, description
),
r AS (
    SELECT *, RANK() OVER (PARTITION BY country ORDER BY rev DESC) AS rk
    FROM p
)
SELECT country, description, ROUND(rev, 2) AS revenue
FROM r
WHERE rk = 1
ORDER BY rev DESC;

-- 10. Cancellation rate (uses the raw table)
SELECT ROUND(100 * COUNT(DISTINCT CASE WHEN invoice LIKE 'C%' THEN invoice END)
             / COUNT(DISTINCT invoice), 1) AS cancellation_rate_pct
FROM transactions;

-- 11. Revenue by day of week
SELECT DAYNAME(invoice_date) AS weekday,
       ROUND(SUM(revenue), 2) AS revenue
FROM clean_tx
GROUP BY weekday, DAYOFWEEK(invoice_date)
ORDER BY DAYOFWEEK(invoice_date);