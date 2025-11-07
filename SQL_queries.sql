--Checking the table and its data types
SELECT *
FROM sales.retail.bright_coffee
LIMIT 10;

-- Exploratory Data Analysis
SELECT DISTINCT store_location
FROM sales.retail.bright_coffee;


-- Checking the products
SELECT DISTINCT product_category
FROM sales.retail.bright_coffee;

-- Checking types of products
SELECT DISTINCT product_type
FROM sales.retail.bright_coffee;

-- Checking details of products
SELECT DISTINCT product_detail
FROM sales.retail.bright_coffee;

-- Checking the inception date
SELECT MIN(transaction_date) AS first_operating_date
FROM sales.retail.bright_coffee;

-- Checking the end date
SELECT MAX(transaction_date) AS last_operating_date
FROM sales.retail.bright_coffee;

-- Checking the possible opening time
SELECT MIN(transaction_time) AS opening_time
FROM sales.retail.bright_coffee;

-- Checking the possible closing time
SELECT MAX(transaction_time) AS closing_time
FROM sales.retail.bright_coffee;

---------------------------------------------------------------------------------------------------
-- analysing days and hours of operating
SELECT transaction_date,
    DAYNAME(transaction_date) AS day_name,
    CASE 
        WHEN DAYNAME(transaction_date) IN ('Sat', 'Sun') THEN 'weekend'
        ELSE 'weekday'
    END AS day_classification,
    MONTHNAME(transaction_date) AS month_name,
        transaction_time,
    CASE
        WHEN transaction_time BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
        WHEN transaction_time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
        WHEN transaction_time >= '17:00:00' THEN 'Evening'
    END AS time_bucket,
    HOUR(transaction_time) AS hour_of_day,
    transaction_id,
    transaction_time,
    store_location,
    store_id,
    product_category,
    product_category,
    product_type,
    product_detail,
    unit_price,
    transaction_qty,
    unit_price*transaction_qty AS Revenue
FROM sales.retail.bright_coffee;

---------------------------------------------------------------------------------------------------
-- Calculating total revenue accross all store between January and June 2023
SELECT
    SUM(transaction_qty * unit_price) AS revenue
FROM sales.retail.bright_coffee,
WHERE transaction_date BETWEEN '2023-01-01' AND '2023-06-30';

---------------------------------------------------------------------------------------------------
-- Comparing total revenue per store between January and June 2023
SELECT store_id,
    SUM(transaction_qty * unit_price) AS revenue
FROM sales.retail.bright_coffee,
WHERE transaction_date BETWEEN '2023-01-01' AND '2023-06-30'
GROUP BY store_id;

---------------------------------------------------------------------------------------------------
-- Calculating each store revenue percentage from total revenue
SELECT store_id,
    SUM(transaction_qty * unit_price) AS revenue,
    SUM(transaction_qty * unit_price) * 100.0 / SUM(SUM(transaction_qty * unit_price)) OVER () AS revenue_percentage
FROM sales.retail.bright_coffee,
WHERE transaction_date BETWEEN '2023-01-01' AND '2023-06-30'
GROUP BY store_id;

---------------------------------------------------------------------------------------------------
-- Rounding the final percentage to 2 decimal places for readability
SELECT store_id,
    SUM(transaction_qty * unit_price) AS revenue,
    ROUND(SUM(transaction_qty * unit_price) * 100.0 / SUM(SUM(transaction_qty * unit_price)) OVER (), 2) 
    AS revenue_percentage
FROM sales.retail.bright_coffee,
WHERE transaction_date BETWEEN '2023-01-01' AND '2023-06-30'
GROUP BY store_id;

---------------------------------------------------------------------------------------------------
-- Checking monthly revenue totals for each store
SELECT store_id,
    TO_CHAR(transaction_date, 'YYYY-MM') AS month,
    SUM(transaction_qty * unit_price) AS monthly_revenue
FROM sales.retail.bright_coffee,
WHERE transaction_date BETWEEN '2023-01-01' AND '2023-06-30'
GROUP BY store_id, TO_CHAR(transaction_date, 'YYYY-MM')
ORDER BY store_id, month;

---------------------------------------------------------------------------------------------------
-- Checking top performing store by revenue
SELECT store_id, revenue
FROM
    (SELECT store_id, SUM(transaction_qty * unit_price) AS revenue
    FROM sales.retail.bright_coffee,
    WHERE transaction_date BETWEEN '2023-01-01' AND '2023-06-30'
    GROUP BY store_id)
ORDER BY revenue DESC
LIMIT 1;

---------------------------------------------------------------------------------------------------

-- Checking the lowest performing store by revenue
SELECT store_id, revenue
FROM
    (SELECT store_id, SUM(transaction_qty * unit_price) AS revenue
    FROM sales.retail.bright_coffee,
    WHERE transaction_date BETWEEN '2023-01-01' AND '2023-06-30'
    GROUP BY store_id)
ORDER BY revenue ASC
LIMIT 1;

---------------------------------------------------------------------------------------------------
-- Top 5 selling products from different store locations
SELECT product_id, store_location, product_category, product_detail,
    SUM(transaction_qty * unit_price) AS revenue
FROM sales.retail.bright_coffee,
WHERE transaction_date BETWEEN '2023-01-01' AND '2023-06-30'
GROUP BY product_id, store_location, product_category, product_detail
ORDER BY revenue DESC
LIMIT 5;

---------------------------------------------------------------------------------------------------
-- Best selling products per specific days
SELECT product_category,
    CASE DAYOFWEEK(transaction_date)
        WHEN 0 THEN 'Sun'
        WHEN 1 THEN 'Mon'
        WHEN 2 THEN 'Tue'
        WHEN 3 THEN 'Wed'
        WHEN 4 THEN 'Thu'
        WHEN 5 THEN 'Fri'
        WHEN 6 THEN 'Sat'
    END AS day_of_week,
    SUM(transaction_qty * unit_price) AS revenue
FROM sales.retail.bright_coffee
WHERE transaction_date BETWEEN '2023-01-01' AND '2023-06-30'
GROUP BY product_category, DAYOFWEEK(transaction_date)
QUALIFY ROW_NUMBER() OVER (PARTITION BY product_category 
ORDER BY revenue DESC) = 1;
