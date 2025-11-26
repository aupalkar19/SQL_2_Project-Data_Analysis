/*
🟩 Analyze Weekly Revenue Query (7.1.1) - Problem
1️ Explain Intro
Problem Statement
Use the EXPLAIN and EXPLAIN ANALYZE commands to analyze the query execution plan for the included query. This will help you understand the cost and time associated with different steps in the query execution.

Use EXPLAIN to find the step with the highest cost.
Use EXPLAIN ANALYZE to find the step with the highest actual execution time.
Recall that both cost and time have a start and stop value in the format: Step (cost=START..STOP …) (actual time=START..STOP …).
Use this query: 
📋 Copy
WITH weekly_revenue AS (
    SELECT
        EXTRACT(WEEK FROM orderdate) AS order_week,
        SUM(quantity * netprice * exchangerate) AS week_revenue
    FROM sales
    WHERE EXTRACT(YEAR FROM orderdate) = 2023
    GROUP BY order_week
)
SELECT
    order_week,
    week_revenue,
    AVG(week_revenue) OVER () AS avg_weekly_revenue,
    100.0 * week_revenue / AVG(week_revenue) OVER () AS pct_of_avg
FROM weekly_revenue
ORDER BY order_week;

Hint
Use EXPLAIN to view the estimated execution plan and identify the step with the highest cost.
Use EXPLAIN ANALYZE to execute the query and identify the step with the highest actual execution time.
 */

EXPLAIN 
WITH weekly_revenue AS (
    SELECT
        EXTRACT(WEEK FROM orderdate) AS order_week,
        SUM(quantity * netprice * exchangerate) AS week_revenue
    FROM sales
    WHERE EXTRACT(YEAR FROM orderdate) = 2023
    GROUP BY order_week
)
SELECT
    order_week,
    week_revenue,
    AVG(week_revenue) OVER () AS avg_weekly_revenue,
    100.0 * week_revenue / AVG(week_revenue) OVER () AS pct_of_avg
FROM weekly_revenue
ORDER BY order_week;

EXPLAIN ANALYZE
WITH weekly_revenue AS (
    SELECT
        EXTRACT(WEEK FROM orderdate) AS order_week,
        SUM(quantity * netprice * exchangerate) AS week_revenue
    FROM sales
    WHERE EXTRACT(YEAR FROM orderdate) = 2023
    GROUP BY order_week
)
SELECT
    order_week,
    week_revenue,
    AVG(week_revenue) OVER () AS avg_weekly_revenue,
    100.0 * week_revenue / AVG(week_revenue) OVER () AS pct_of_avg
FROM weekly_revenue
ORDER BY order_week;

-- Analyze yourself 



/*

🟩 Impact of LIMIT on Query Performance (7.1.2) - Problem
1️ Explain Intro
Problem Statement
Use DBeaver's built-in EXPLAIN EXECUTION PLAN feature to analyze the execution time of a query that retrieves customer keys from the sales table. Compare the execution time with and without using LIMIT to understand the impact on performance.

Use the EXPLAIN EXECUTION PLAN feature in DBeaver to analyze the query.
Compare the execution time with and without the LIMIT clause.
Hint
Highlight relevant query in DBeaver if multiple queries are present.
Use the EXPLAIN EXECUTION PLAN button in the script pane.
Ensure the proper settings are selected in the 'Extra EXPLAIN settings'.

*/

-- Without LIMIT
SELECT *
FROM sales;

/*
Node Type	Entity	Cost			Rows	Time	Condition
Seq Scan	sales	0.00 - 4518.73	199873	17.176	[NULL]
 */

--With LIMIT
SELECT *
FROM sales
LIMIT 10;

/*
Node 	Type		Entity	Cost	Rows	Time	Condition
Limit	[NULL]		0.00 - 0.23		10		0.021	[NULL]
Seq Scan	sales	0.00 - 4518.73	10		0.018	[NULL]
 */ 




/*
🟨 Common Execution Plan Steps (7.1.3) - Problem
1️ Explain Intro
Problem Statement
Create a query that demonstrates the use of common execution plan steps such as Seq Scan, Hash Join, HashAggregate, Sort, and Filter. This will help you understand how these steps are used in query execution.

Use EXPLAIN to analyze the query execution plan.
Ensure the query includes a sequential scan, hash join, hash aggregate, sort, and filter.

Hint
Seq Scan: Happens when Postgres reads every row in a table — common when no index is used
Hash Join: Happens when joining large tables on equality, and no sorting or indexes are involved
HashAggregate: Happens during GROUP BY when input isn’t pre-sorted, so Postgres builds a hash table to group
Sort: Happens when query needs ordered output (e.g. ORDER BY, DISTINCT, Merge Join) but data isn’t already sorted
Filter: Happens when a WHERE condition is evaluated row-by-row — common on top of Seq Scans and Index Scans
 */ 

-- We will find the total_revenue spend by customers for the year 2024 and beyond across different stores

EXPLAIN ANALYZE
WITH customer_revenue AS (
	SELECT
		s.customerkey,
	 	s.storekey,
	    SUM(s.quantity * s.netprice * s.exchangerate) AS net_revenue
	FROM sales s
	WHERE EXTRACT(YEAR FROM s.orderdate) >= 2024
		GROUP BY 
		s.customerkey,
	 	s.storekey
	ORDER BY 
		s.customerkey,
	 	s.storekey
)

SELECT
	cr.customerkey,
	CONCAT(TRIM(c.givenname), ' ' , TRIM(c.surname) ) AS full_name,
	cr.storekey,
	cr.net_revenue
FROM customer_revenue cr
	INNER JOIN customer c ON c.customerkey = cr.customerkey;

	


	

