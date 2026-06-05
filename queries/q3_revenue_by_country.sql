-- revenue by country
SELECT
    country,
    COUNT(DISTINCT customer) AS total_customers,
    COUNT(DISTINCT invoice) AS total_transactions,
    ROUND(SUM(revenue)::NUMERIC, 2) AS total_revenue,
    ROUND(SUM(revenue)::NUMERIC / COUNT(DISTINCT customer), 2) AS revenue_per_customer
FROM retail_clean
GROUP BY country
ORDER BY total_revenue DESC;