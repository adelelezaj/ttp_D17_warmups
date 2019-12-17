-- Run the following query to create a modified customers "table" (actually a VIEW)
-- This version of the customers table will have (duplicate rows) to simulate
-- multiple users with the same name.

-- THIS ONLY NEEDS TO RUN ONCE. After that, you can delete the query.

CREATE OR REPLACE VIEW customers_mod AS(
SELECT * FROM customers 
	UNION ALL
SELECT * FROM customers WHERE contact_name ILIKE '%an%'
	UNION ALL
SELECT * FROM customers WHERE contact_name ILIKE '%ia%');

SELECT * FROM customers_mod ORDER BY contact_name;

-- ** What's a VIEW? In brief, a VIEW is a psuedo-table that is attached to the original tables 
-- it's created from, but as far is this exercise is concerned, it's a custom table.

-- Where going to autogenerate username for our customers using the customers_mod VIEW (see above).

-- Step 1: We want the user name to be the first 5 letters of their last name combined with the 
-- first 3 letters of their first name, all lower case.
-- Example George Clooney -> cloongeo

SELECT contact_name,split_part(LOWER(contact_name), ' ',2)::VARCHAR(5) 
|| split_part(LOWER(contact_name),' ',1)::VARCHAR(3) as user_name
FROM customers_mod
ORDER BY user_name;

-- Step 2: Notice that there are customers with the same? Can you think of a way to 
-- make sure that all user names are unique? Add to the query in Step 1 so any users
-- with the same name as another username as a unique number attached to it
-- eg. (cloongeo1), but the first username has no digits appened to it.

with cte as ( 
	SELECT contact_name,split_part(LOWER(contact_name), ' ',2)::VARCHAR(5) 
|| split_part(LOWER(contact_name),' ',1)::VARCHAR(3) as user_name,
ROW_NUMBER() OVER (PARTITION BY contact_name ORDER BY contact_name) - 1 as repeat
FROM customers_mod
)
SELECT *, 
    CASE WHEN repeat = 0 THEN user_name
    ELSE user_name || repeat
    END as user_name_
FROM cte