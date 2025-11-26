# Intermediate SQL - CONTOSO Sales Analysis

## Overview
This SQL project analyzes customer behavior, revenue generation, and retention patterns using the Contoso sales dataset. By building an optimized cohort analysis view, the project centralizes key metrics such as lifetime value, purchase history, and cohort grouping. Advanced SQL techniques; which include window functions, percentiles, and performance-optimized aggregations; were used to create actionable insights for segmentation, revenue trends, and churn behavior. The final analysis provides a clear understanding of customer value distribution, declining cohort revenue trends, and significant retention challenges, guiding data-driven business decisions.

## Business Questions
1. **Customer Segmentation:** How the customers are segmented across tier-values based on their life-time value (ltv)?

2. **Cohort Analysis:** How do different customer groups generate revenue across yearly cohorts?

3. **Customer Retention:**  How many customers are retained actively across the year cohorts?

## Analysis Approach

### 0. SQL Project View 
- Built a virtual table (i.e. Project View) to centralize all the the appropiate data parameters. 

- **FIXED**: 
	``` sql
	sum(s.netprice * s.quantity::double PRECISION / s.exchangerate) AS total_net_revenue
	```
	- Added a divide sign  for exchangerate

🖥️ Query: [0_project_view.sql](/0_project_view.sql)
``` sql

``` sql
--Optimized
CREATE VIEW cohort_analysis AS
WITH customer_revenue AS (
	SELECT
		s.customerkey,
		s.orderdate,
		sum(s.netprice * s.quantity::double PRECISION / s.exchangerate) AS total_net_revenue,
		count(s.orderkey) AS num_orders,
		
		-- We got rid of these GROUP BY column dependencies 
			-- AND wrapped them in an aggregate to maintain the same effect 
			-- AND run without errors WOW WOW
		MAX(c.countryfull) AS countryfull,
		MAX(c.age) AS age,
		MAX(c.givenname) AS givenname,
		MAX(c.surname) AS surname
	FROM
		sales s
	
	-- Switching to INNER JOIN as it is more optimized... less execution time...
		-- We verify the nature of LEFT and INNER JOIN on this view 
				--by checking the row counts of unoptimized and optimized version to be same
	INNER JOIN customer c ON
		c.customerkey = s.customerkey
		
	GROUP BY
		s.customerkey,
		s.orderdate
		-- We got rid of these GROUP BY column dependencies 
			-- AND wrapped them in an aggregate to maintain the same effect 
			-- AND run without errors WOW WOW
)
 SELECT
	customerkey,
	orderdate,
	total_net_revenue,
	num_orders,
	countryfull,
	age,
	concat(TRIM(BOTH FROM givenname), ' ', TRIM(BOTH FROM surname)) AS cleaned_name,
	min(orderdate) OVER (
		PARTITION BY customerkey
	) AS first_purchase_date,
	EXTRACT(YEAR FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM
	customer_revenue cr;

```
**⚒️ Project View Details:**

- Optimizes performance by removing unnecessary GROUP BY columns and replacing them with MAX() aggregates, reducing sorting and computation overhead by ~20%.

- Improves join efficiency through the use of an INNER JOIN (validated by matching row counts), ensuring faster execution without affecting accuracy.

- Enriches the dataset by adding cleaned customer names, first purchase dates, and cohort years using window functions — enabling deeper cohort, retention, and revenue analysis.

### 1. Customer Segmentation
- Customers were segmented based over: 
	- below 25th percentile:  '1 - Low-Value'
	- below and equal to 75th percentile: '2 - Mid-Value' 
	- Above 75th percentile : '3 - High-Value'

- Total and average ltv across these tiers were calculated

🖥️ Query: [1_customer_segmentation.sql](/1_customer_segmentation.sql)
``` sql
WITH customer_ltv AS (
	SELECT 
		customerkey,
		cleaned_name,
		SUM(total_net_revenue) AS total_ltv
	FROM cohort_analysis
	GROUP BY
		customerkey,
		cleaned_name
	ORDER BY
		customerkey
), customer_segments AS (

	SELECT 
		PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY total_ltv) AS ltv_25th_percentile,
		PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY total_ltv) AS ltv_75th_percentile 
	FROM customer_ltv
	
), segment_values AS (

	SELECT 
		c.*,
		CASE
			WHEN c.total_ltv < cs.ltv_25th_percentile THEN '1 - Low-Value'
			WHEN c.total_ltv <= cs.ltv_75th_percentile THEN '2 - Mid-Value'
			ELSE '3 - High-Value'
		END AS customer_segment
		
	FROM customer_ltv c,
		 customer_segments cs
)

SELECT 
	customer_segment,
	SUM(total_ltv) AS total_ltv,
	COUNT(customerkey) AS customer_count,
	SUM(total_ltv) / COUNT(customerkey) AS avg_ltv
FROM segment_values
GROUP BY 
	customer_segment
ORDER BY 
	customer_segment DESC
```

**📈 Visualization:**

![1_customer_segmentation](/Images/1_customer_segmentation.png)

📊 **Key Findings:**
- High-Value customers contribute ~66% of total lifetime value despite being only one-third of all customers.

- Mid-Value customers contribute ~32% of total LTV, showing strong commercial importance.

- Low-Value customers contribute only ~2%, indicating minimal impact on revenue even though many exist.

💡 **Business Insights**
- Retention & nurturing of High-Value customers should be top priority, as they drive the majority of revenue.

- Mid-Value customers are strong candidates for targeted upsell programs, as small improvements could significantly increase total revenue.

- Low-Value customers require low-cost engagement strategies, since aggressive marketing here offers minimal ROI.


### 2. Cohort Analysis 
- Tracked revenue and customer count per cohorts 
- Cohorts were grouped by the first year of purchase
- Analyzed customer retention at a cohort level

🖥️ Query: 
[2_cohort_analysis.sql](/2_cohort_analysis.sql)

```sql
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

```

**📈 Visualization:**

![2_cohort_analysis](/Images/2_cohort_analysis.png)

📊 **Key Findings:**
- Peak customer revenue occurred in cohorts 2016–2019, consistently above $2,750–$3,050 per customer.

- Post-2019 cohorts show a steady decline, with 2023–2024 falling to $2,043 and $1,878 — a drop of nearly 35% from peak years.

- The exponential trend line confirms a long-term downward revenue trend, indicating reduced customer value in more recent cohorts.

💡 **Business Insights**
- Strengthen early-stage engagement: Since older cohorts maintain higher revenue, focusing on the first 6–12 months can significantly influence long-term customer value.

- Rebalance acquisition strategy: Newer cohorts (2022–2024) generate far lower revenue. It suggests weaker targeting, lower-quality leads, or shift in customer behavior.

- Introduce premium nurturing paths: Customers resembling earlier high-value cohorts (2016–2019) should be identified early and placed into higher-touch retention campaigns.

### 3. Customer Retention
- Determining Active vs Churned customers across 6-month Interval

- Found the last purchase date using ROW_NUMBER() window function and ordering  that partitioned data by descending

- Rectifying the analysis to account for only sales data beyond the 6-Month interval from current max sale date in the whole dataset such that:
	- first_purchase_date < MAX(orderdate) - 6 months
	- Otherwise, the customer were REALLY NOT active over the past six months peroid

🖥️ Query: [3_retention_analysis.sql](/3_retention_analysis.sql)

``` sql
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
```

**📈 Visualization:**

![total_customer_Active_vs_churned](/Images/3_total_customer_active_vs_churned.png)
![customer_cohort_retention_analysis](/Images/3_customer_cohort_retention.png)

📊 **Key Findings:**
- Over 90% of customers are churned, indicating extremely weak long-term retention.

- Active customer rate remains consistently low (~8–10%) across all cohorts, regardless of year.

- Even newer cohorts (2022–2023) show only slightly higher retention, suggesting early churn is a persistent pattern.

💡 **Business Insights**
- Retention strategy overhaul is needed — focusing on improving post-first-purchase engagement, onboarding, and remarketing.

- High-volume churn = major revenue leakage; reactivation campaigns for mid-value & high-value past customers offer strong ROI.

- Cohort behavior is highly predictable, allowing Contoso to design targeted lifecycle automation before customers enter the churn window.










## Strategic Recommendations

1. Strengthen early-stage engagement programs to improve customer value in the first 6–12 months, where long-term revenue is shaped.

2. Launch targeted retention workflows for mid-value and high-value customers, including loyalty programs, exclusive offers, and personalized communication.

3. Improve customer acquisition targeting to attract higher-quality customers similar to strong historical cohorts (2016–2019).

4. Implement automated churn-risk prediction using order recency and activity thresholds to intervene before customers lapse.

5. Develop low-cost engagement paths (email drips, in-app nudges, bundled incentives) to maintain awareness among low-value customers without heavy marketing spend.

## Technical Details
- **Database:** PostgreSQL 16
- **Analysis Tools:** DBeaver, pgAdmin, and VS Code
- **Visualization:** ChatGPT

##  Author
**Aditya Upalkar**  
SQL Final Project — CONTOSO Sales Analysis  
[Under Supervision of Luke Barousse ](https://www.linkedin.com/in/luke-b/)  
 © 2025