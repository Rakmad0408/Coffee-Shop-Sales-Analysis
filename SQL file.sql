select * from coffee_shop_sales;

DESC coffee_shop_sales;

UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, "%H:%i:%s");

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

select * from coffee_shop_sales;

-- KPI REQUIREMENTS

# 1. Total Sales Analysis
# # -> Calculate the totaal sales for each respective month
SELECT MONTHNAME(transaction_date) AS "Month", CONCAT(ROUND((ROUND(SUM(unit_price*transaction_qty)))/1000), "K") AS "Total Sales"
FROM coffee_shop_sales
GROUP BY YEAR(transaction_date), MONTHNAME(transaction_date);

# # -> Determine the month-on-month increse or decrese in sales
SELECT MONTH(transaction_date) AS "Month",	-- Number of the Month
ROUND(SUM(unit_price*transaction_qty)) AS "Total Sales",	-- Total Sales Column
ROUND(((SUM(unit_price*transaction_qty)-LAG(SUM(unit_price*transaction_qty), 1)	-- MOnth Sales Difference
OVER (ORDER BY MONTH(transaction_date)))/LAG(SUM(unit_price*transaction_qty), 1)	-- Divide by Previous Month Sales
OVER (ORDER BY MONTH(transaction_date)))*100, 2) AS "MoM-gowth in sales (%)"	-- Percentage
FROM coffee_shop_sales
-- WHERE MONTH(transaction_date) 
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);


# # -> Calculate the difference in sales between the selected month and the previous month



# 2. Total Orders Analysis
# # -> 
SELECT MONTHNAME(transaction_date) AS "Month", COUNT(transaction_id) AS "Total Orders"
FROM coffee_shop_sales
GROUP BY YEAR(transaction_date), MONTHNAME(transaction_date);

# # -> 
SELECT MONTH(transaction_date) AS "Month",	-- Number of the Month
COUNT(transaction_id) AS "Total Orders",	-- Total Sales Column
ROUND(((COUNT(transaction_id)-LAG(COUNT(transaction_id), 1)	-- MOnth Sales Difference
OVER (ORDER BY MONTH(transaction_date)))/LAG(COUNT(transaction_id), 1)	-- Divide by Previous Month Sales
OVER (ORDER BY MONTH(transaction_date)))*100, 2) AS "MoM-gowth in sales (%)"	-- Percentage
FROM coffee_shop_sales
-- WHERE MONTH(transaction_date) 
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);




# 3. Total Quantity Sold Analysis
# # -> 

SELECT MONTHNAME(transaction_date) AS "Month", SUM(transaction_qty) AS "Total Quantity Sold"
FROM coffee_shop_sales
GROUP BY YEAR(transaction_date), MONTHNAME(transaction_date);


SELECT MONTH(transaction_date) AS "Month",	-- Number of the Month
SUM(transaction_qty) AS "Total Quantity Sold",	-- Total Sales Column
ROUND(((SUM(transaction_qty)-LAG(SUM(transaction_qty), 1)	-- MOnth Sales Difference
OVER (ORDER BY MONTH(transaction_date)))/LAG(SUM(transaction_qty), 1)	-- Divide by Previous Month Sales
OVER (ORDER BY MONTH(transaction_date)))*100, 2) AS "MoM-gowth in sales (%)"	-- Percentage
FROM coffee_shop_sales
-- WHERE MONTH(transaction_date) 
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);


-- CHARTS REQUIREMENTS
# 1. Calendar Heat Map

SELECT
	CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000, 1), 'K') AS TOtal_Sales,
    CONCAT(ROUND(SUM(transaction_qty)/1000, 1), 'K') AS Total_Qty_Sold,
    CONCAT(ROUND(COUNT(transaction_id)/1000, 1), 'K') AS Total_Orders
FROM coffee_shop_sales
WHERE
	transaction_date = '2023-03-27';
    
    
# 2. Sales Ananlysis by Weekdays and Weekends

Sun = 1
Mon = 2
.. Sat = 7

SELECT
	CASE WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
    ELSE 'Weekdays'
    END AS day_type,
    CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000, 1), 'K') AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5	-- May Month
GROUP BY day_type;


# # 3.

SELECT
	store_location,
    CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000, 2), 'K') AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5	-- May
GROUP BY store_location
ORDER BY Total_Sales DESC;


# # 4.

SELECT
	AVG(total_sales) AS Avg_Sales
FROM
	(
    SELECT SUM(transaction_qty*unit_price) AS total_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5
    GROUP BY transaction_date
    ) AS Internal_Query;
    
    


SELECT DAY(transaction_date) AS Day_Name,
SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY Day_Name
ORDER BY Day_Name;


SELECT day_of_month,
total_sales,
CASE 
	WHEN total_sales > avg_sales THEN "Above Average"
    WHEN total_sales < avg_sales THEN "Below Average"
    ELSE "Equal to Average"
    END AS sales_status
FROM
(SELECT 
DAY(transaction_date) AS day_of_month,
SUM(unit_price*transaction_qty) AS total_sales,
AVG(SUM(unit_price*transaction_qty)) OVER() AS avg_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY day_of_month) AS sales_data
ORDER BY day_of_month;





# 5.
SELECT product_category,
SUM(unit_price*transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_category
ORDER BY total_sales DESC;


# 6.

SELECT 
	product_type,
    SUM(unit_price*transaction_qty) AS total_sales
FROM
	coffee_shop_sales
WHERE MONTH(transaction_date) = 5 AND product_category = "Coffee"
GROUP BY product_type
ORDER BY total_sales DESC
LIMIT 10;


# 7.

SELECT 
    SUM(unit_price*transaction_qty) AS total_sales,
    SUM(transaction_qty) AS Total_qty_sold,
    COUNT(*) AS Total_Orders
FROM
	coffee_shop_sales
WHERE MONTH(transaction_date) = 5	-- May
AND DAYOFWEEK(transaction_date) = 2	-- Monday
AND HOUR(transaction_time) = 8;	-- Hour No 8



SELECT 
	HOUR(transaction_time) AS Hour,
    SUM(unit_price*transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY Hour
ORDER BY Hour;