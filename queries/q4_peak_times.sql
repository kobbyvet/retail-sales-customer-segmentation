--Peak shopping hours and days
SELECT
    EXTRACT(DOW FROM invoicedate) AS day_number,
    TO_CHAR(invoicedate, 'Day') AS day_name,
    EXTRACT(HOUR FROM invoicedate) AS hour,
    COUNT(DISTINCT invoice) AS total_transactions,
    ROUND(SUM(revenue)::NUMERIC, 2) AS total_revenue
FROM retail_clean
GROUP BY 
    EXTRACT(DOW FROM invoicedate),
    TO_CHAR(invoicedate, 'Day'),
    EXTRACT(HOUR FROM invoicedate)
ORDER BY day_number, hour;