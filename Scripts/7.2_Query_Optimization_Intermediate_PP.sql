/*
 
🟩 Optimize Revenue Query (7.2.1) - Problem
2️ Optimization Techniques
Problem Statement
Optimize the following query to improve its performance by applying intermediate optimization techniques. The current query retrieves data from the sales, customer, and store tables using multiple joins and groups the results by several columns. Your task is to rewrite the query to make it more efficient.

Analyze the given query and identify inefficiencies.
Apply intermediate optimization techniques to improve the query, focusing on minimizing JOINS

Here is the inefficient query:
📋 Copy
SELECT 
    s.orderkey, 
    c.customerkey, 
    st.storekey, 
    SUM(s.quantity * s.netprice * s.exchangerate) AS total_revenue
FROM sales s
    LEFT JOIN customer c ON s.customerkey = c.customerkey
    FULL OUTER JOIN store st ON s.storekey = st.storekey
GROUP BY 
    s.orderkey, 
    c.customerkey, 
    st.storekey
ORDER BY 
    c.customerkey, 
    st.storekey;

Hint
Minimize JOIN usage and pulling in columns from the minimum amount of tables. (i.e., look at the columns and what alternate tables can they be found in?)

**/
EXPLAIN ANALYZE
SELECT 
    s.orderkey, 
    c.customerkey, 
    st.storekey, 
    SUM(s.quantity * s.netprice * s.exchangerate) AS total_revenue
FROM sales s
    LEFT JOIN customer c ON s.customerkey = c.customerkey
    FULL OUTER JOIN store st ON s.storekey = st.storekey
GROUP BY 
    s.orderkey, 
    c.customerkey, 
    st.storekey
ORDER BY 
    c.customerkey, 
    st.storekey;


--Optimizing
EXPLAIN ANALYZE
SELECT 
    MAX(s.orderkey) AS orderkey, 
    s.customerkey, 
    s.storekey, 
    SUM(s.quantity * s.netprice * s.exchangerate) AS total_revenue
FROM sales s
GROUP BY 
    s.customerkey, 
    s.storekey
ORDER BY 
    s.customerkey,
    s.storekey;






/*
🟨 Optimize Sales Query (7.2.2) - Problem
2️ Optimization Techniques
Problem Statement
This task involves modifying a SQL query to calculate revenue per order line item, create a unique integer identifier (order_line), remove unneeded columns, and analyze performance.

Goal: Calculate the total revenue (quantity * netprice * exchangerate) for each individual order line item in the sales table.
Create Identifier: Derive a new integer column named order_line that uniquely identifies each specific order line item row (consider combining orderkey and linenumber).
Refactor Query: Adjust the query's SELECT list and GROUP BY clause to achieve the line item revenue calculation. Remove unnecessary columns and include the new order_line along with relevant fields like customerkey and orderdate.
Analyze: Use EXPLAIN ANALYZE on your final query.

Here is the query to optimize:

📋 Copy
SELECT 
    orderkey, 
    linenumber,
    customerkey, 
    storekey, 
    orderdate,
    SUM(quantity * netprice * exchangerate) AS total_revenue
FROM sales
GROUP BY 
    orderkey, 
    linenumber,
    customerkey, 
    storekey,
    orderdate
ORDER BY
    customerkey, 
    storekey;

Hint
The column that don't add any value to the final output is: storekey
Convert order_line to an integer to optimize the grouping process.
*/

EXPLAIN ANALYZE
SELECT 
    orderkey, 
    linenumber,
    customerkey, 
    storekey, 
    orderdate,
    SUM(quantity * netprice * exchangerate) AS total_revenue
FROM sales
GROUP BY 
    orderkey, 
    linenumber,
    customerkey, 
    storekey,
    orderdate
ORDER BY
    customerkey, 
    storekey;





--My solution
EXPLAIN ANALYZE
SELECT
	CONCAT(orderkey, linenumber)::INT AS order_line,
    customerkey, 
    MAX(orderdate) AS orderdate,
    SUM(quantity * netprice * exchangerate) AS total_revenue
FROM sales
GROUP BY 
	customerkey,
	order_line
ORDER BY
	total_revenue DESC;




--Luke's solution
EXPLAIN ANALYZE
SELECT 
    customerkey,
    CONCAT(orderkey, linenumber)::INT AS order_line,
    orderdate,
    SUM(quantity * netprice * exchangerate) AS total_spent
FROM sales
GROUP BY 
    customerkey,
    order_line,
    orderdate
ORDER BY total_spent DESC;
