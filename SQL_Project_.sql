-- =========================================================
-- SQL Portfolio Project: Retail Sales Analysis
-- Database: MySQL
-- =========================================================
-- This file contains 20 SQL questions with their solutions.
-- =========================================================


-- =========================================================
-- PART A: Basic SELECT Queries
-- =========================================================

-- Q1. Select the full name, phone number, and email address of all customers.
SELECT
    full_name,
    phone,
    email
FROM customers;


-- Q2. Find the product name and unit price of products priced above 50,000.
--     Sort the results from highest price to lowest price.
SELECT
    product_name,
    unit_price
FROM products
WHERE unit_price > 50000
ORDER BY unit_price DESC;


-- Q3. Display all orders whose status is 'Cancelled' or 'Returned'.
SELECT *
FROM orders
WHERE status IN ('Cancelled', 'Returned');


-- Q4. Display all customers whose email address is missing (NULL).
SELECT *
FROM customers
WHERE email IS NULL;


-- Q5. Display stores that opened after 1 January 2021.
--     Sort the results by opening date, earliest first.
SELECT *
FROM stores
WHERE open_date > '2021-01-01'
ORDER BY open_date;


-- =========================================================
-- PART B: Aggregations, GROUP BY, JOINs, and Subqueries
-- =========================================================

-- Q6. Find total sales (SUM(total_amount)) for each city by joining
--     orders to customers. Sort cities from highest sales to lowest.
SELECT
    c.city,
    SUM(o.total_amount) AS total_sales
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY total_sales DESC;


-- Q7. Count the total number of orders for each store.
--     Show the store with the most orders first.
SELECT
    store_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY store_id
ORDER BY total_orders DESC;


-- Q8. Calculate the average order value (AVG(total_amount)) for each
--     payment method.
SELECT
    payment_method,
    AVG(total_amount) AS average_order_value
FROM orders
GROUP BY payment_method;


-- Q9. Find the top 5 best-selling products by quantity.
--     Join order_items to products and rank by SUM(quantity).
SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC
LIMIT 5;


-- Q10. Use GROUP BY and HAVING to show categories that contain
--      more than 4 products.
SELECT
    category_id,
    COUNT(*) AS total_products
FROM products
GROUP BY category_id
HAVING COUNT(*) > 4;


-- Q11. List customers who have never placed an order.
--      Use a LEFT JOIN and IS NULL.
SELECT
    c.*
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;


-- Q12. Show the most expensive product in each category.
--      Display category_name, product_name, and unit_price.
SELECT
    c.category_name,
    p.product_name,
    p.unit_price
FROM products AS p
JOIN categories AS c
    ON p.category_id = c.category_id
WHERE p.unit_price = (
    SELECT MAX(p2.unit_price)
    FROM products AS p2
    WHERE p2.category_id = p.category_id
)
ORDER BY c.category_name;


-- Q13. Show total revenue for each store, including store_name and city.
--      Join orders to stores.
SELECT
    s.store_name,
    s.city,
    SUM(o.total_amount) AS total_revenue
FROM orders AS o
JOIN stores AS s
    ON o.store_id = s.store_id
GROUP BY
    s.store_id,
    s.store_name,
    s.city;


-- =========================================================
-- PART C: Advanced SQL — CTEs, Window Functions, CASE, and Functions
-- =========================================================

-- Q14. Use a CTE to calculate each customer's total lifetime spend.
--      List customers whose total spend is greater than 100,000.
WITH customer_spend AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spend
    FROM orders
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_spend
FROM customer_spend
WHERE total_spend > 100000;


-- Q15. Use RANK() or DENSE_RANK() to rank customers by total spend
--      within each city.
WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.city,
        SUM(o.total_amount) AS total_spend
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id,
        c.city
)
SELECT
    customer_id,
    city,
    total_spend,
    RANK() OVER (
        PARTITION BY city
        ORDER BY total_spend DESC
    ) AS spend_rank
FROM customer_spend;


-- Q16. Use ROW_NUMBER() to find each customer's most recent order.
--      Return exactly one row per customer.
WITH ranked_orders AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        status,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC, order_id DESC
        ) AS rn
    FROM orders
)
SELECT
    customer_id,
    order_id,
    order_date,
    status,
    total_amount
FROM ranked_orders
WHERE rn = 1;


-- Q17. Use LAG() to compare each customer's current order amount
--      with their previous order amount. Name the previous amount
--      column previous_order_amount.
SELECT
    customer_id,
    order_id,
    order_date,
    total_amount,
    LAG(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS previous_order_amount
FROM orders;


-- Q18. Use CASE WHEN to classify orders by size:
--      Small:  below 5,000
--      Medium: 5,000 through 50,000
--      Large:  above 50,000
--      Count the number of orders in each category.
SELECT
    CASE
        WHEN total_amount < 5000 THEN 'Small'
        WHEN total_amount <= 50000 THEN 'Medium'
        ELSE 'Large'
    END AS order_size,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_size;


-- Q19. Use date functions to show the monthly sales trend.
--      Display the order count and total revenue for each month.
--      MySQL: DATE_FORMAT(order_date, '%Y-%m')
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;


-- Q20. Use string functions to create a masked customer list.
--      Display the first letter of each customer's name followed by ***.
SELECT
    CONCAT(
        SUBSTRING(full_name, 1, 1),
        '***'
    ) AS masked_customer
FROM customers;
