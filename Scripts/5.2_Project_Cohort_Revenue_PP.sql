/*
 * 🟨 Monthly Revenue & Customer Trends (5.2.1) - Problem
	2️ Project Cohort Revenue
	Problem Statement
	This is the first bonus question to our project: 
	Calculate the monthly revenue, customer totals, and average customer revenue to explore why we are seeing customers spend less over time.

	Use the cohort_analysis view to perform the analysis.
	Group the orderdate by month and calculate the total revenue, total number of customers, and average revenue per customer for each month.
	Order the results by month to observe the trends over time.

	Hint
	Use DATE_TRUNC to group the data by month.
	Use SUM to calculate the total revenue.
	Use COUNT(DISTINCT ...) to find the total number of unique customers.
	Calculate the average revenue per customer by dividing total revenue by total customers.
 * 
 */

SELECT
	--cohort_year,
	TO_CHAR(orderdate,'YYYY-MM') AS order_yyyy_mm,
	SUM(total_net_revenue) AS monthly_net_revenue,
	COUNT(DISTINCT customerkey) AS customer_count,
	
	SUM(total_net_revenue)/COUNT(DISTINCT customerkey) AS avg_revenue_per_customer
	
	
FROM cohort_analysis
GROUP BY order_yyyy_mm --cohort_year
ORDER BY order_yyyy_mm;





/*
🟥 3 Month Rolling Average (5.2.2) - Problem
2️ Project Cohort Revenue
Problem Statement
This is the final bonus question to our project: Calculate the 3 month rolling average of monthly revenue, customer totals, and average customer revenue to better explore why we are seeing customers spend less over time.

Use the query from the previous question (5.2.2) to start your analysis by putting it into a CTE.
Compute the rolling averages for total revenue, total customers, and customer revenue over a 3-month window.
Order the results by month to observe the trends over time.

Hint:
Use a Common Table Expression (CTE) to calculate monthly metrics.
Use AVG with a window function to calculate the rolling averages.
Define the frame clause for each metric that gets the one preceding month, current month, and the one following month (I.e., 3 months).
*/

WITH monthly_revenue AS (
	SELECT
		--cohort_year,
		TO_CHAR(orderdate,'YYYY-MM') AS order_yyyy_mm,
		SUM(total_net_revenue) AS monthly_net_revenue,
		COUNT(DISTINCT customerkey) AS customer_count,
		
		SUM(total_net_revenue)/COUNT(DISTINCT customerkey) AS avg_revenue_per_customer
		
		
	FROM cohort_analysis
	GROUP BY order_yyyy_mm --cohort_year
	ORDER BY order_yyyy_mm
)

SELECT
mr.order_yyyy_mm,

mr.monthly_net_revenue,
AVG(mr.monthly_net_revenue) OVER(
	ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
) AS roll_avg_3_monthly_net_revenue,

mr.customer_count,
AVG(mr.customer_count) OVER(
	ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
) AS roll_avg_3_customer_count,

-- mr.avg_revenue_per_customer, 
AVG(mr.avg_revenue_per_customer) OVER(
	ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
) AS roll_avg_3_avg_revenue_per_customer


FROM monthly_revenue mr;

