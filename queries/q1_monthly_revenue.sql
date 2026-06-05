--monthly revenue trend

SELECT
    TO_CHAR(DATE_TRUNC('month', invoicedate), 'YYYY-MM') AS month,
    COUNT(DISTINCT invoice) AS total_transactions,
    COUNT(DISTINCT customer) AS active_customers,
    ROUND(SUM(revenue)::NUMERIC, 2) AS monthly_revenue
FROM retail_clean
GROUP BY DATE_TRUNC('month', invoicedate)
ORDER BY DATE_TRUNC('month', invoicedate);