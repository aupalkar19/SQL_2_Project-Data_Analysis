WITH customer_last_purchase AS (	
	SELECT 
		customerkey,
		cleaned_name,
		orderdate,
		ROW_NUMBER() OVER(PARTITION BY customerkey ORDER BY orderdate DESC) AS rn,
		first_purchase_date,
		cohort_year
	FROM cohort_analysis 
),

churned_customers AS (
SELECT 
	customerkey,
	cleaned_name,
	first_purchase_date,
	orderdate AS last_purchase_date,
	
	-- (SELECT MAX(orderdate) FROM sales) = 2024-04-20
	CASE
		WHEN orderdate >= (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 Months' THEN 'Active'
		ELSE 'Churned'
	END AS customer_status,
	cohort_year
	
	
	
FROM customer_last_purchase
WHERE rn = 1
	/*
	 * When we checkout the first_purcahse_date DESC and last_purchase_date DESC we find they are equal
	 * meaning the customer are REALLY NOT active over the past six months
	 * they are active before that six-month peroid, it will skew our output more towards active side 
	 * so there is a bias
	 * 
	 * so we will account for this
	 */
	 AND first_purchase_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 Months'
)

SELECT 
	cohort_year,
	customer_status,
	
	-- We need one aggregation for GROUP BY and one aggregation for Window function
	COUNT(customerkey) AS num_customers,
	SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year) AS total_customers,
	
	ROUND(COUNT(customerkey) / SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year), 2) AS status_percentage
	
	
FROM churned_customers
GROUP BY cohort_year, customer_status