USE retail;

SELECT segment,
       COUNT(*) AS customers,
       ROUND(SUM(monetary), 0) AS revenue,
       ROUND(100 * SUM(monetary) / (SELECT SUM(monetary) FROM rfm_segments), 1) AS revenue_pct
FROM rfm_segments
GROUP BY segment
ORDER BY revenue DESC;