/*
 *  🟩 Recreate Store Description (6.2.1) - Problem
	2️ String Formatting
	Problem Statement
	In this task, you will explore the store table to understand how the description column is constructed. Your goal is to recreate this column using the CONCAT function and another column from the dataset.

	Inspect the description column in the store table.
	Use the CONCAT function to recreate the description column by combining a string with another column from the store table.
	Compare your result with the original description column.

	Hint
	Use the CONCAT function to combine a string with the column of interest.
 * 
 */

SELECT 
	description, 
	CONCAT('Contoso Store ', state) AS duplicate_description
FROM store;





/*
 * 
 * 🟨 Format Store Description and Date (6.2.2) - Problem
	2️ String Formatting
	Problem Statement
	In this task, you will create a formatted string for each store in the store table. This string will include the store's description in uppercase and its opening date in a specific format.

	Query the storekey and also create a new column that combines the store's description in uppercase with its opening date.
	Format the other column similiar to this: CONTOSO STORE AUSTRALIAN CAPITAL TERRITORY, Opened: January 01, 2010
	Use the TRIM, CONCAT, UPPER, and TO_CHAR functions to achieve the desired format.

	Hint
	Use UPPER to convert the description to uppercase.
	Use CONCAT to combine the formatted strings.
 * 
 */

SELECT
	storekey,
	CONCAT(TRIM(UPPER(description)), ', Opened: ', TO_CHAR(opendate, 'FMMonth DD, YYYY')) AS store_details
FROM store;








/*
🟥 Recreate Product Code (6.2.3) - Problem
2️ String Formatting
Problem Statement
In this task, you will recreate the productcode column in the product table using the subcategorykey and a ranking function.

Inspect the productcode and subcategorykey columns in the product table.
Use the ROW_NUMBER() function to generate a rank for each product within its subcategory.
Use the CONCAT and LPAD functions to recreate the productcode by combining the subcategorykey with the ranked number.

Hint
Use ROW_NUMBER() to assign a rank to each product within its subcategory and ordered by it's productcode
Use LPAD to ensure the rank is formatted as a three-digit number.

Course Note: We didn't cover this formula during the lesson so here is a breakdown of LPAD:
LPAD(text, length, fill) pads the left side of a string with a specified character until it reaches the desired length. 
LPAD('5', 2, '0') returns '05'
LPAD('12', 4, '0') returns '0012'
LPAD('123', 3, '0') returns '123'
*/

WITH code_struct AS (
SELECT 
	productcode, 
	subcategorykey,
	ROW_NUMBER() OVER(PARTITION BY subcategorykey ORDER BY productcode) AS ranked_productcode
FROM product
)

SELECT 
	*,
	CONCAT(subcategorykey, LPAD(CAST(ranked_productcode AS TEXT),3,'0')) AS recreated_productcode
FROM code_struct