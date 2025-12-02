-- Dropping all tables/functions 
DROP FUNCTION IF EXISTS get_month; 
DROP TABLE IF EXISTS detailed_table_2007_payments;
DROP TABLE IF EXISTS summary_table_top_5_category_payments_1st_quarter;
DROP FUNCTION update_summary_table() CASCADE;
DROP TRIGGER IF EXISTS new_summary_table ON detailed_table_2007_payments;
DROP PROCEDURE IF EXISTS refreshing_tables();


-- 1. CREATING USER DEFINED FUNCTIONS THAT TRANSFORMS DATA

CREATE OR REPLACE FUNCTION get_month(payment_date timestamp)
	RETURNS  varchar(10)
	LANGUAGE  plpgsql
AS 
$$
DECLARE 
    month_char VARCHAR(10);
BEGIN
    SELECT TRIM(TO_CHAR(payment_date, 'Month')) 
    INTO month_char;

    RETURN month_char;
END;
$$;


-- TESTING 
--SELECT trim(to_char(TIMESTAMP '2007-04-08 20:34:01.996577', 'Month'));
SELECT get_month(TIMESTAMP '2007-04-08 20:34:01.996577');  -- returns april

-- 2A. creating detailed table with transformation


CREATE TABLE IF NOT EXISTS detailed_table_2007_payments (
    title VARCHAR(255),
    payment_amount NUMERIC(5,2),
    payment_month VARCHAR(10),
    category_name VARCHAR(25)
);

SELECT * FROM detailed_table_2007_payments;

-- 2B.  now create the summary table 

CREATE TABLE IF NOT EXISTS summary_table_top_5_category_payments_1st_quarter (
    category_name VARCHAR(25),
    total_payments NUMERIC(6,2)
);


--3A now create the  trigger function 


CREATE OR REPLACE FUNCTION update_summary_table()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    DROP TABLE summary_table_top_5_category_payments_1st_quarter;

    CREATE TABLE IF NOT EXISTS summary_table_top_5_category_payments_1st_quarter (
        category_name VARCHAR(25),
        total_payments NUMERIC(6,2)
    );

    INSERT INTO summary_table_top_5_category_payments_1st_quarter
    SELECT category_name,
           SUM(payment_amount) AS total_payments
    FROM detailed_table_2007_payments
    WHERE payment_month IN ('January', 'February', 'March')
    GROUP BY category_name
    ORDER BY total_payments DESC
    LIMIT 5;
  RETURN NEW;
END;
$$;

-- 3B. Then create the actual trigger

CREATE TRIGGER new_summary_table
AFTER INSERT OR UPDATE OR DELETE
ON detailed_table_2007_payments
FOR EACH STATEMENT
EXECUTE PROCEDURE update_summary_table();




-- 4. populating the detailed table  - triggers the trigger function to update summary 
INSERT INTO detailed_table_2007_payments
SELECT f.title,
       p.amount AS payment_amount,
       get_month(p.payment_date) AS payment_month,
       c.name AS category_name
FROM category c
INNER JOIN film_category fc
    ON c.category_id = fc.category_id
INNER JOIN film f
    ON fc.film_id = f.film_id
INNER JOIN inventory i
    ON i.film_id = f.film_id
INNER JOIN rental r
    ON r.inventory_id = i.inventory_id
INNER JOIN payment p
    ON r.rental_id = p.rental_id
WHERE EXTRACT(YEAR FROM payment_date) = 2007
ORDER BY amount DESC;


SELECT * FROM detailed_table_2007_payments; -- should return new populated table
SELECT * FROM summary_table_top_5_category_payments_1st_quarter; -- should return new populated summary table

-- Testing 
-- inserting new data into detailed table -> returns updated summary table
INSERT INTO detailed_table_2007_payments 
VALUES ('NBA final', 500.00, 'January', 'Sports');  

SELECT * FROM summary_table_top_5_category_payments_1st_quarter; ---> returns Sports 3058.33

DELETE FROM detailed_table_2007_payments 
WHERE title = 'NBA final';   

SELECT * FROM summary_table_top_5_category_payments_1st_quarter; ---> returns previous Sports amount 2558.33


-- 5. now creaate the stored procedure

CREATE OR REPLACE PROCEDURE refreshing_tables()
    LANGUAGE plpgsql
AS
$$
BEGIN
    DELETE FROM detailed_table_2007_payments;
    DELETE FROM summary_table_top_5_category_payments_1st_quarter;

    INSERT INTO detailed_table_2007_payments
    SELECT f.title,
           p.amount AS payment_amount,
           get_month(p.payment_date) AS payment_month,
           c.name AS category_name
    FROM category c
    INNER JOIN film_category fc
        ON c.category_id = fc.category_id
    INNER JOIN film f
        ON fc.film_id = f.film_id
    INNER JOIN inventory i
        ON i.film_id = f.film_id
    INNER JOIN rental r
        ON r.inventory_id = i.inventory_id
    INNER JOIN payment p
        ON r.rental_id = p.rental_id
    WHERE EXTRACT(YEAR FROM payment_date) = 2007
    ORDER BY amount DESC;

    RETURN;
END;
$$;

CALL refreshing_tables();


-- test the stored procedure 

SELECT * FROM detailed_table_2007_payments; 

SELECT * FROM summary_table_top_5_category_payments_1st_quarter;---> returns previous Sports amount

