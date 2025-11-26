--5.1.1 Create a View:
CREATE VIEW customer_age_groups AS
SELECT 
    customerkey,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthday)) * 12 + EXTRACT(MONTH FROM AGE(CURRENT_DATE, birthday)) AS age_in_months,
    AGE(CURRENT_DATE, birthday) AS age,
    CASE 
        WHEN birthday >= CURRENT_DATE - INTERVAL '25 years' THEN 'Under 25'
        WHEN birthday >= CURRENT_DATE - INTERVAL '49 years' THEN '25-50'
        ELSE '50+'
    END AS age_group
FROM customer;


--5.1.2 Update a view: 
-- Go to Views -> customer_age_groups -> Source + Properties -> Update -> Save
SELECT *
FROM customer_age_groups;

--5.1.3 Retrieve the view 
SELECT 
    customerkey,
    age
FROM customer_age_groups
WHERE age_group = 'Elder'
ORDER BY age;

--5.1.4 Modify View Column Name
ALTER VIEW customer_age_groups RENAME COLUMN age TO customer_age;


SELECT * FROM customer_age_groups;



--5.1.5 Drop Customer Age Groups View 
DROP VIEW IF EXISTS customer_age_groups