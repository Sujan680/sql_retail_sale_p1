-- SQL Retail Saless Analysis - p1
CREATE DATABASE sql_project_p1;

-- Create Table
DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales 
(
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(10),
	age INT,
	category VARCHAR(15),
	quantiy INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
)

SELECT *
FROM
	retail_sales;

ALTER TABLE retail_sales
RENAME COLUMN quantiy to quantity;


	-- Identifying the duplicates
	SELECT
		*,
		RANK() OVER(PARTITION BY transactions_id, sale_date,sale_time,customer_id,gender, age, category, quantity, price_per_unit, cogs, total_sale) AS row_num
	FROM
		retail_sales;
		
	-- Writing CTEs for finding duplicate:
	WITH cte_duplicates AS (
		SELECT
		*,
		RANK() OVER(PARTITION BY transactions_id, sale_date,sale_time,customer_id,gender, age, category, quantity, price_per_unit, cogs, total_sale) AS row_num
	FROM
		retail_sales
	)
	SELECT *
	FROM
		cte_duplicates
	WHERE
		row_num > 1;

-- Checking for NULL in the columns
SELECT *
FROM
	retail_sales
WHERE
	transactions_id IS NULL;

SELECT *
FROM
	retail_sales
WHERE
	sale_date IS NULL;

SELECT *
FROM
	retail_sales
WHERE
	transactions_id IS NULL 
	OR
	sale_date IS NULL 
	OR
	sale_time IS NULL 
	OR
	gender IS NULL 
	OR
	category IS NULL 
	OR
	quantity IS NULL 
	OR
	price_per_unit IS NULL 
	OR
	cogs IS NULL 
	OR
	total_sale IS NULL;

	-- Removing the NULL values from table
	DELETE FROM retail_sales
	WHERE
		transactions_id IS NULL 
	OR
	sale_date IS NULL 
	OR
	sale_time IS NULL 
	OR
	gender IS NULL  
	OR
	category IS NULL 
	OR
	quantity IS NULL 
	OR
	price_per_unit IS NULL 
	OR
	cogs IS NULL 
	OR
	total_sale IS NULL;

	-- Data Exploration

	-- How many sales we have ?
	SELECT COUNT(*) FROM retail_sales;

	-- How many unique costumer we have ?
	SELECT COUNT(DISTINCT(customer_id)) FROM retail_sales;

	-- How may category we have ?
	SELECT DISTINCT category FROM retail_sales;

	-- Analysis and Findings:
	--1. Write a SQL query to retrieve all columns for sales made on '2022-11-05' ?

		SELECT *
		FROM
			retail_sales
		WHERE
			sale_date = '2022-11-05';

	--2. Write SQL query to retrieve all transactions where the category is  'Clothing' and the quantity sold is more than 4 in the month of Nov-2022 ?

		SELECT 
			*
		FROM
			retail_sales
		WHERE
			category = 'Clothing'
			AND 
			(quantity >= 4 AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11');

	--- 3. Write a SQL query to calculate the total sales (total_sale) for each category?

			SELECT
				category,
				SUM(total_sale) total_sales_by_category,
				COUNT(*) total_orders
			FROM
				retail_sales
			GROUP BY 
				category;

	--4. Write a SQL query to find the average age of customers who purchased items from 'Beauty' category;

		SELECT
			ROUND(AVG(age),0) avg_age_customers
		FROM
			retail_sales
		WHERE
			category = 'Beauty';
	--5. Write a SQL query to find all transactions where the total_sale is greater than 1000;

		SELECT
			*
		FROM
			retail_sales
		WHERE
			total_sale > 1000;

	--6. Write a SQL query to find the total number of transactions (transactions_id) made by each gender in each category;

		SELECT
			gender,
			category,
			COUNT(*) total_transactions
		FROM
			retail_sales
		GROUP BY
			gender,
			category
		ORDER BY
			category;

	--7. Write a SQL query to calculate the average sale for each month. FInd out the best selling month in each year.
	
			WITH cte_best_selling_month AS(
			SELECT
				EXTRACT(MONTH FROM sale_date) months,
				EXTRACT(YEAR FROM sale_date) years,
				ROUND(AVG(total_sale :: numeric),2) avg_sale,
				RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY ROUND(AVG(total_sale :: numeric),2) DESC) row_num
			FROM
				retail_sales
			GROUP BY
				months, years
			)
			SELECT
				*
			FROM
				cte_best_selling_month
			WHERE
				row_num = 1;

	--8. Write a SQL query to find the top 5 customers based on the highest total sales;
		
		SELECT
			customer_id,
			SUM(total_sale) as total_sales
		FROM
			retail_sales
		GROUP BY
			customer_id
		ORDER BY
			total_sales DESC
		LIMIT 5;

	--9.  Write a SQL query to find the number of unique customers who purchased itmes from each category.

			SELECT
				category,
				COUNT(DISTINCT(customer_id)) unique_customer
			FROM
				retail_sales
			GROUP BY
				category;


	--10. Write a SQL query to create shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening > 17)

			WITH cte_hourly_sale AS (
			SELECT 	
				*,
				CASE	
					WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
					WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
					ELSE 'Evening'
				END AS shift
			FROM
				retail_sales
			)
			SELECT 
				shift,
				COUNT(*) number_orders
			FROM
				cte_hourly_sale
			GROUP BY
				shift;
