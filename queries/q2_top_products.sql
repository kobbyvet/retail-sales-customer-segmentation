--top 20 best selling product
SELECT
    stockcode,
    description,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(revenue)::NUMERIC, 2) AS total_revenue,
    COUNT(DISTINCT customer) AS unique_customers
FROM retail_clean
WHERE description IS NOT NULL
GROUP BY stockcode, description
ORDER BY total_revenue DESC
LIMIT 20;