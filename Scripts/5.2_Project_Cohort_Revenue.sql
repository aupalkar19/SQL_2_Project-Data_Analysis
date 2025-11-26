--Customer Revneue by first purchase year
SELECT
	cohort_year,
	COUNT(DISTINCT customerkey) AS total_customers,
	SUM(total_net_revenue) AS total_revenue,
	SUM(total_net_revenue) / COUNT(DISTINCT customerkey) AS customer_revenue
FROM cohort_analysis

-- Upon further insepction we came to know that majority of the revenue contribution comes
	-- from the first purchase date for a customer cohort so we will analyze accordingly...
WHERE orderdate = first_purchase_date 

GROUP BY cohort_year

-- We found out that in a time adjusted revenue setting for customer cohorts, 
-- it is more prononuced that the customer_revenue is reducing based on the exponential trendline


/*
WITH purchase_days AS (
    SELECT
        customerkey,
        ca.total_net_revneue,
        orderdate - MIN(orderdate) OVER (PARTITION BY customerkey) AS days_since_first_purchase
    FROM cohort_analysis ca
)
SELECT
    days_since_first_purchase,
    SUM(total_net_revneue) AS total_revenue,
    SUM(total_net_revneue) / (SELECT SUM(total_net_revneue) FROM cohort_analysis) * 100 AS percentage_of_total_revenue,
    SUM(SUM(total_net_revneue) / (SELECT SUM(total_net_revneue) FROM cohort_analysis) * 100)
        OVER (ORDER BY days_since_first_purchase) AS cumulative_percentage_of_total_revenue
FROM purchase_days
GROUP BY 1
ORDER BY 1;
*/
