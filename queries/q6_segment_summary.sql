--customer segment summary 
SELECT
    segment,
    COUNT(customer) AS total_customers,
    ROUND(AVG(recency_days), 0) AS avg_recency_days,
    ROUND(AVG(frequency), 1) AS avg_frequency,
    ROUND(AVG(monetary)::NUMERIC, 2) AS avg_monetary,
    ROUND(SUM(monetary)::NUMERIC, 2) AS total_revenue
FROM (
    WITH rfm_base AS (
        SELECT
            customer,
            MAX(invoicedate::DATE) AS last_purchase_date,
            COUNT(DISTINCT invoice) AS frequency,
            ROUND(SUM(revenue)::NUMERIC, 2) AS monetary,
            (SELECT MAX(invoicedate::DATE) FROM retail_clean) - MAX(invoicedate::DATE) AS recency_days
        FROM retail_clean
        GROUP BY customer
    ),
    rfm_scores AS (
        SELECT
            customer,
            recency_days,
            frequency,
            monetary,
            NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
            NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
            NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
        FROM rfm_base
    )
    SELECT
        customer,
        recency_days,
        frequency,
        monetary,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
            WHEN r_score >= 3 AND f_score <= 2 AND m_score <= 2 THEN 'Promising'
            WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4 THEN 'Cant Lose Them'
            WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost Customers'
            ELSE 'Needs Attention'
        END AS segment
    FROM rfm_scores
) segmented
GROUP BY segment
ORDER BY total_revenue DESC;