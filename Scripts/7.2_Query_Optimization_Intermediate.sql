-- You can reduce execution time by reducing the group by conditioning
-- Ex. we removed linenumber column along GROUP BY and saved a lot of time
EXPLAIN ANALYZE
SELECT 
    customerkey,
    orderdate,
    orderkey,
    linenumber,
    SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales
GROUP BY 
    customerkey, 
    orderdate,
    orderkey,
    linenumber;

EXPLAIN ANALYZE
SELECT 
    customerkey,
    orderdate,
    orderkey,
    SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales
GROUP BY 
    customerkey, 
    orderdate,
    orderkey;




-- Minimizing the number and types of joins
EXPLAIN ANALYZE
SELECT 
    c.customerkey,
    c.givenname,
    c.surname,
    p.productname,
    s.orderdate,
    s.orderkey,
    d.year
FROM sales s
INNER JOIN customer c ON s.customerkey = c.customerkey
INNER JOIN product p ON p.productkey = s.productkey
INNER JOIN date d ON d.date = s.orderdate;

--We could minimize join in this case by using EXTRACT to get year form orderdate itself
EXPLAIN ANALYZE
SELECT 
    c.customerkey,
    c.givenname,
    c.surname,
    p.productname,
    s.orderdate,
    s.orderkey,
    EXTRACT(YEAR FROM s.orderdate) AS date
FROM sales s
INNER JOIN customer c ON s.customerkey = c.customerkey
INNER JOIN product p ON p.productkey = s.productkey;








--Optimize ORDER BY
EXPLAIN ANALYZE
SELECT 
    customerkey,
    orderdate,
    orderkey,
    SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales
GROUP BY 
    customerkey, 
    orderdate,
    orderkey
ORDER BY
    net_revenue DESC,
    customerkey,
    orderdate,
    orderkey;

-- Limit number of columns in ORDER BY clause
-- Avoid sorting on computed columns or function calls
-- Make sure ordering just one column that has cascading effect across other columns
-- Use indexed columns for sorting to leverage existing database indexes

EXPLAIN ANALYZE
SELECT 
    customerkey,
    orderdate,
    orderkey,
    SUM(quantity * netprice * exchangerate) AS net_revenue
FROM sales
GROUP BY 
    customerkey, 
    orderdate,
    orderkey
ORDER BY
    customerkey,
    orderdate,
    orderkey;


-- We will optimize our view in cohort_analysis
