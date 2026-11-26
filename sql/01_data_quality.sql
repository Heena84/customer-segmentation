USE retail;

SELECT
    COUNT(*)                      AS total_rows,
    SUM(customer_id IS NULL)      AS null_customer_id,
    SUM(quantity < 0)             AS negative_quantity,
    SUM(invoice LIKE 'C%')        AS cancelled_invoices,
    SUM(price = 0)                AS zero_price,
    SUM(price < 0)                AS negative_price
FROM transactions;

SELECT COUNT(*) AS duplicate_groups, SUM(cnt - 1) AS extra_rows
FROM (
    SELECT COUNT(*) AS cnt
    FROM transactions
    GROUP BY invoice, stock_code, description, quantity,
             invoice_date, price, customer_id, country
    HAVING COUNT(*) > 1
) d;
