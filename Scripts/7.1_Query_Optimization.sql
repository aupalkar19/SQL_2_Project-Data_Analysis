-- EXPLAIN 
-- EXPLAIN ANALYZE

-- When to understand to use EXPLAIN and EXPLAIN ANALYZE
	-- We use EXPLAIN over EXPLAIN ANALYZE if the dataset is too large to save excution times and cost as well

EXPLAIN
SELECT *
FROM sales;

EXPLAIN ANALYZE
SELECT *
FROM sales;
/*
 	Seq Scan on sales  (cost=0.00..4518.73 rows=199873 width=68) (actual time=0.017..20.278 rows=199873 loops=1)
	Planning Time: 0.111 ms
	Execution Time: 28.170 ms
 */


EXPLAIN ANALYZE
SELECT 
	customerkey,
	SUM(netprice * exchangerate * quantity) AS net_revenue
FROM sales
GROUP BY customerkey;
/*
 HashAggregate  (cost=7017.14..7390.54 rows=37340 width=12) (actual time=95.768..103.502 rows=49487 loops=1)
  	Group Key: customerkey
  	Batches: 1  Memory Usage: 4881kB
  	->  Seq Scan on sales  (cost=0.00..4518.73 rows=199873 width=24) (actual time=0.031..17.495 rows=199873 loops=1)
	Planning Time: 0.256 ms
	Execution Time: 106.909 ms
*/




EXPLAIN ANALYZE
SELECT 
	customerkey,
	SUM(netprice * exchangerate * quantity) AS net_revenue
FROM sales
WHERE orderdate >= '2024-01-01'
GROUP BY customerkey;
/*
 HashAggregate  (cost=5144.51..5234.92 rows=9041 width=12) (actual time=24.593..25.208 rows=4097 loops=1)
  Group Key: customerkey
  Batches: 1  Memory Usage: 913kB
  ->  Seq Scan on sales  (cost=0.00..5018.41 rows=10088 width=24) (actual time=20.234..21.320 rows=10131 loops=1)
        Filter: (orderdate >= '2024-01-01'::date)
        Rows Removed by Filter: 189742
	Planning Time: 0.254 ms
	Execution Time: 25.756 ms
 */



--Using the Expain tab to get details in DBEAVER (Ctrl + Shift + E)
SELECT 
	customerkey,
	SUM(netprice * exchangerate * quantity) AS net_revenue
FROM sales
WHERE orderdate >= '2024-01-01'
GROUP BY customerkey;




--Using LIMIT for a large dataset
-- Ex.
EXPLAIN ANALYZE
SELECT *
FROM sales;
/*
Seq Scan on sales  (cost=0.00..4518.73 rows=199873 width=68) (actual time=0.021..19.822 rows=199873 loops=1)
Planning Time: 0.103 ms
Execution Time: 31.667 ms
*/

EXPLAIN ANALYZE
SELECT *
FROM sales 
LIMIT 10;
/*
 Limit  (cost=0.00..0.23 rows=10 width=68) (actual time=0.021..0.025 rows=10 loops=1)
  ->  Seq Scan on sales  (cost=0.00..4518.73 rows=199873 width=68) (actual time=0.019..0.021 rows=10 loops=1)
Planning Time: 0.150 ms
Execution Time: 0.045 ms
*/ 


-- Avoid SELECT * for a large dataset
EXPLAIN ANALYZE
SELECT *
FROM sales;

EXPLAIN ANALYZE
SELECT customerkey
FROM sales;

-- In this case, Postgres is more optimized for SELECT * against SELECT customerkey
-- It becomes an issue tho when the query cannot be preprocessed for SELECT * 
-- Leading to the program lagging and crashing
-- So better optimize over column_names



-- Using WHERE instead of HAVING; Filter before aggregation for efficiency
EXPLAIN ANALYZE
SELECT 
	customerkey,
	SUM(netprice * exchangerate * quantity) AS net_revenue
FROM sales
GROUP BY customerkey;

