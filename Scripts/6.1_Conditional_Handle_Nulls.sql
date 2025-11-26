-- Create a table of "real" data jobs
CREATE TABLE data_jobs (
    id INT,
    job_title VARCHAR(30),
    is_real_job VARCHAR(20),
    salary INT
);

-- Insert our "professional" opinions
INSERT INTO data_jobs VALUES
(1, 'Data Analyst', 'yes', NULL),
(2, 'Data Scientist', NULL, 140000),
(3, 'Data Engineer', 'kinda', 120000);

SELECT * FROM data_jobs;

-- Demostration of COALESCE function
-- Replaces [NULL] i.e. 'undecided value' with a string value
-- You can cast even catergorical variables like job_title
	-- But the dataypes should be matching
SELECT
	job_title,
	
	COALESCE (is_real_job, 'No') AS is_real_job,
	
	-- You can cast even catergorical variables like job_title
	-- But the dataypes should be matching
	
	COALESCE (salary::VARCHAR, job_title) AS salary
	--OR COALESCE (salary::TEXT, job_title) AS salary
	--OR COALESCE (salary::TEXT, job_title, 'default value') 
	
FROM data_jobs;





--Demostration of NULLIF function
-- Returns null if exp_1 = exp_2; otherwise returns exp_1
-- Could either be columns or single value
SELECT 
	job_title,
	NULLIF(is_real_job, 'kinda') AS is_real_job,
	
	-- You can cast even catergorical variables like salary
	-- But the dataypes should be matching
	-- NULLIF(is_real_job, salary::VARCHAR) AS is_job_valid,
	
	salary

FROM data_jobs;













-- Real world example
 WITH sales_data AS ( 
	SELECT
		customerkey,
		SUM(quantity * netprice * exchangerate) AS net_revenue
	FROM sales
	GROUP BY
		 customerkey
		 -- HAVING SUM(quantity * netprice * exchangerate) IS NULL
		 -- Currently there is no null values here 
		 -- But we can merge it with customer table to expose the null values for customers
 ) 	
 
 SELECT
 	/*
 	c.customerkey,
 	s.net_revenue,
 	COALESCE(s.net_revenue, 0) AS net_revenue
 	*/
 	
 	AVG(NULLIF(s.net_revenue, 0)) spending_customers_avg_net_revenue, -- avg_without_zeros_without_customers_having_zero_net_revenue
 	AVG(s.net_revenue) AS spending_customers_avg_net_revenue, -- avg_without_zeros
 	AVG(COALESCE(s.net_revenue, 0)) AS all_customers_avg_net_revenue -- avg_with_zeros
 	
 	
 	-- In the main prject tho, our analysis would strictly be based upon spending customers 
 	-- i.e. avg_without_zeros meaning the nulls are ignored
 	
 FROM customer c
 LEFT JOIN sales_data s ON s.customerkey = c.customerkey


