--RFM segmentation
-- Step 1: Calculate RFM metrics per customer
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

-- Step 2: Score each metric 1-5
rfm_scores AS (
    SELECT
        customer,
        last_purchase_date,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)

-- Step 3: Combine scores and assign segments
SELECT
    customer,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total,
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
ORDER BY rfm_total DESC;