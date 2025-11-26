--Customer Revneue by first purchase year
SELECT
	cohort_year,
	COUNT(DISTINCT customerkey) AS total_customers,
	SUM(total_net_revenue) AS total_revenue,
	SUM(total_net_revenue) / COUNT(DISTINCT customerkey) AS customer_revenue
FROM cohort_analysis

-- Upon further inspection we came to know that majority of the revenue contribution comes
	-- from the first purchase date for a customer cohort so we will analyze accordingly...
WHERE orderdate = first_purchase_date 

GROUP BY cohort_year