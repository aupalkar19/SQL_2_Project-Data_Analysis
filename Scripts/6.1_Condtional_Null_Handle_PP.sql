/*
 	🟩 Clean Store Key (6.1.1) - Problem
	1️ Conditional Handle Nulls
	Problem Statement
	In this task, you will clean the storekey for the 'Online store' in the store table. This current number for the 'Online store' was just a place holder and needs to be replaced with a new value.

	Use the COALESCE and NULLIF functions to replace the storekey of 'Online store' with 0.
	Select the storekey and the cleaned storekey as storekey_clean.

	Hint
	Use NULLIF to compare the storekey with a placeholder value.
	Use COALESCE to replace NULL values with 0.
 */


SELECT 
	st.storekey,
	COALESCE(NULLIF(st.storekey, 999999),0) AS storekey_clean
	
FROM store st;



/*
🟩 Store Revenue Calculation (6.1.2) - Problem
1️ Conditional Handle Nulls
Problem Statement
Calculate the total net revenue for each store, including those that have no sales. This will help in understanding the revenue distribution across all stores.

Use a LEFT JOIN to include all stores, even those without sales.
In one column, calculate the total revenue for each store.
In another column, use COALESCE to replace NULL total revenue values with 0.
Order by the storekey at the end.

Hint
Use LEFT JOIN to ensure all stores are included in the results.
Use SUM to calculate the total revenue for each store.
Use COALESCE to handle NULL values in the revenue calculation.
*/

WITH store_sales AS (
	SELECT 
		sa.storekey,
		SUM(sa.netprice * sa.quantity * sa.exchangerate) AS net_revenue
	FROM sales sa
	GROUP BY sa.storekey
)

SELECT 
	st.storekey,
	ss.net_revenue,
	COALESCE(ss.net_revenue, 0) AS net_revenue_null_handled
	
FROM store st
	LEFT JOIN store_sales ss ON ss.storekey = st.storekey;

/*
 * Better solution:
 *
	SELECT
	    st.storekey,
	    st.description,
	    SUM(s.quantity * s.netprice * s.exchangerate) AS total_revenue,
	    COALESCE(SUM(s.quantity * s.netprice * s.exchangerate), 0) AS total_revenue_coalesce
	FROM store st
	LEFT JOIN sales s ON st.storekey = s.storekey
	GROUP BY st.storekey, st.description
	ORDER BY st.storekey;
 * 
 */







/*
🟨 Average Store Revenue (6.1.3) - Problem
1️ Conditional Handle Nulls
Problem Statement
Calculate the average revenue per store both including and excluding zero-revenue stores. This will help in understanding the average revenue distribution across all stores.

Use a Common Table Expression (CTE) to calculate revenue both including and excluding zero-revenue stores. (See Problem 6.1.2)
Use COALESCE to handle NULL values in the revenue calculation.
Calculate the average revenue for stores with and without NULL values.
Hint
Use COALESCE to replace NULL values with 0 in the revenue calculation.
Use AVG to calculate the average revenue for stores.
*/

WITH store_sales AS (
	SELECT
		sa.storekey,
		SUM(sa.netprice * sa.quantity * sa.exchangerate) AS net_revenue
	FROM sales sa
	GROUP BY sa.storekey
)

SELECT 
     -- st.storekey,
     -- net_revenue,
     -- COALESCE(net_revenue, 0) AS net_revenue_null_handled
     
     CAST(AVG(net_revenue) AS INTEGER) AS avg_net_revenue,
     CAST(AVG(COALESCE(net_revenue, 0)) AS INTEGER) AS avg_net_revenue_null_handled
     
FROM store st
	LEFT JOIN store_sales ss ON st.storekey = ss.storekey
