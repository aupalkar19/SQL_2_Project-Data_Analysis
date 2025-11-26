-- title: sales copy table
WITH sales_copy AS (
	SELECT
	FROM
		sales
	LIMIT 10
)
-- DBeaver treats space as a semi-colon so it may thwart your program
-- We fix it by going to Windows -> Perferences -> SQL Editor
SELECT 
	*
FROM
	sales_copy;

-- title: customer count
SELECT 
	COUNT(*)
FROM
	customer
