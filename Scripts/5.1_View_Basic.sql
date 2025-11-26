--View is a virtual table
CREATE VIEW daily_revenue AS
SELECT 
	orderdate,
	SUM(netprice * quantity * exchangerate) AS net_revenue
FROM 
	sales 
GROUP BY orderdate;


SELECT *
FROM daily_revenue;


-- Drop the view
DROP VIEW daily_revenue

