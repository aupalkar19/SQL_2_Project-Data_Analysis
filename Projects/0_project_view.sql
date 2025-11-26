/*
 * 
 * AT THE VERY LAST PART of the view... WE have adjusted:
 *  	SUM(netprice * quantity * exchangerate) AS net_revenue TO
 * 		SUM(netprice * quantity / exchangerate) AS net_revenue
 */


CREATE VIEW cohort_analysis AS
WITH customer_revenue AS (
	SELECT 
		s.customerkey,
		s.orderdate,
		SUM(s.netprice * s.quantity * s.exchangerate) AS total_net_revenue,
		COUNT(s.orderkey) AS num_orders,
		c.countryfull,
		c.age,
		c.givenname,
		c.surname
		
	FROM sales s
	LEFT JOIN customer c ON c.customerkey = s.customerkey
	GROUP BY 
		c.customerkey, 
		s.customerkey, 
		s.orderdate,
		c.countryfull,
		c.age,
		c.givenname,
		c.surname
)

SELECT 
	cr.*,
	MIN(cr.orderdate) OVER(PARTITION BY cr.customerkey) AS first_purchase_date,
	EXTRACT(YEAR FROM MIN(cr.orderdate) OVER(PARTITION BY cr.customerkey)) AS cohort_year
	
FROM customer_revenue cr;

DROP VIEW cohort_analysis;

/*6.2 String Formatting: Concatenating givenname and surname*/

CREATE OR REPLACE VIEW public.cohort_analysis AS
WITH customer_revenue AS (
         SELECT s.customerkey,
            s.orderdate,
            sum(s.netprice * s.quantity::double precision * s.exchangerate) AS total_net_revenue,
            count(s.orderkey) AS num_orders,
            c.countryfull,
            c.age,
            c.givenname,
            c.surname
           FROM sales s
             LEFT JOIN customer c ON c.customerkey = s.customerkey
          GROUP BY c.customerkey, s.customerkey, s.orderdate, c.countryfull, c.age, c.givenname, c.surname
        )
 SELECT customerkey,
    orderdate,
    total_net_revenue,
    num_orders,
    countryfull,
    age,
    CONCAT(TRIM(givenname), ' ', TRIM(surname)) AS cleaned_name,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_revenue cr;






-- 7.2 Query Optimization Intermediate 
-- Unoptimized Version
EXPLAIN ANALYZE
WITH customer_revenue AS (
	SELECT
		s.customerkey,
		s.orderdate,
		sum(s.netprice * s.quantity::double PRECISION * s.exchangerate) AS total_net_revenue,
		count(s.orderkey) AS num_orders,
		c.countryfull,
		c.age,
		c.givenname,
		c.surname
	FROM
		sales s
	LEFT JOIN customer c ON
		c.customerkey = s.customerkey
	GROUP BY
		c.customerkey,
		s.customerkey,
		s.orderdate,
		c.countryfull,
		c.age,
		c.givenname,
		c.surname
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

--DROP VIEW cohort_analysis; 




/*
 * 
 * AT THE VERY LAST PART of the view... WE have adjusted:
 *  	SUM(netprice * quantity * exchangerate) AS net_revenue TO
 * 		SUM(netprice * quantity / exchangerate) AS net_revenue
 * 
 */
	
 -- First drop the table 
DROP VIEW cohort_analysis; 


-- Then implement the below view
--Optimized
--EXPLAIN ANALYZE
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