CREATE DATABASE ecommerce_analytics;

USE ecommerce_analytics;

CREATE TABLE customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

CREATE TABLE orders (
    order_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,

    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);


CREATE TABLE order_items (
    order_id VARCHAR(32),
    order_item_id INT,
    product_id VARCHAR(32),
    seller_id VARCHAR(32),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),

    PRIMARY KEY (order_id, order_item_id),

    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
);


SELECT *
FROM customers
LIMIT 5;


SELECT *
FROM orders
LIMIT 5;


SELECT *
FROM order_items
LIMIT 5;

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT
    c.customer_id,
    COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id;


SELECT
    o.order_status,
    COUNT(o.order_id) AS order_count
FROM orders o
GROUP BY o.order_status
ORDER BY order_count DESC;

SELECT
    o.customer_id,
    COUNT(o.order_id) AS order_count
FROM orders o
GROUP BY o.customer_id
ORDER BY order_count DESC
LIMIT 10;

SELECT
    p.product_category_name,
    COUNT(oi.order_id) AS total_orders
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_orders DESC
LIMIT 10;


SELECT
    p.product_category_name,
    SUM(oi.price) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    o.order_id,
    SUM(oi.price + oi.freight_value) AS order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY order_value DESC
LIMIT 10;


SELECT
    payment_type,
    COUNT(*) AS payment_count,
    SUM(payment_value) AS total_payment
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment DESC;



SELECT
    review_score,
    COUNT(*) AS review_count
FROM order_reviews
GROUP BY review_score
ORDER BY review_score DESC;




SELECT
    o.order_status,
    AVG(
        DATEDIFF(
            o.order_delivered_customer_date,
            o.order_purchase_timestamp
        )
    ) AS avg_delivery_days
FROM orders o
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY o.order_status
ORDER BY avg_delivery_days DESC;

SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_spent
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 10;


SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    SUM(oi.price) AS total_revenue
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY order_month
ORDER BY order_month;

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY total_spent DESC;

SELECT
    o.order_status,
    COUNT(*) AS total_orders,
    SUM(CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END    ) AS late_orders
FROM orders o
GROUP BY o.order_status
ORDER BY late_orders DESC;

SELECT
    p.product_category_name,
    AVG(r.review_score) AS avg_review_score,
    COUNT(r.review_id) AS total_reviews
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN order_reviews r
    ON oi.order_id = r.order_id
GROUP BY p.product_category_name
HAVING COUNT(r.review_id) >= 100
ORDER BY avg_review_score DESC
LIMIT 10;



SELECT
    p.product_category_name,
    SUM(oi.price) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(oi.price) DESC
    ) AS revenue_rank
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY revenue_rank;



SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(COUNT(
            DISTINCT CASE
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                THEN o.order_id
            END
        ) * 100.0 / COUNT(DISTINCT o.order_id),
        2
    ) AS late_delivery_rate
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY late_delivery_rate DESC;


SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_spent,
    CASE
        WHEN COUNT(DISTINCT o.order_id) = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC;



WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        SUM(oi.price) AS total_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY order_month
)
SELECT
    order_month,
    total_revenue,
    ROUND(
        total_revenue - LAG(total_revenue) OVER (ORDER BY order_month),
        2
    ) AS revenue_change
FROM monthly_sales
ORDER BY order_month;



SELECT
    payment_type,
    ROUND(AVG(payment_value), 2) AS avg_payment_value,
    MAX(payment_value) AS max_payment_value,
    MIN(payment_value) AS min_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY avg_payment_value DESC;

SELECT
    p.product_category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_product_price
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    c.customer_state,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(r.review_id) AS total_reviews
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_reviews r
    ON o.order_id = r.order_id
GROUP BY c.customer_state
ORDER BY avg_review_score DESC;


SELECT
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS total_sellers,
    SUM(oi.price) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY total_revenue DESC;

SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY order_year;


SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM orders o
JOIN order_reviews r
    ON o.order_id = r.order_id
GROUP BY o.order_status
ORDER BY avg_review_score DESC;

SELECT
    p.product_category_name,
    SUM(oi.price) AS total_revenue,
    ROUND(
        SUM(oi.price) * 100.0 /
        SUM(SUM(oi.price)) OVER (),
        2
    ) AS revenue_percentage
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    p.product_category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(oi.price) DESC
    ) AS revenue_rank
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
HAVING COUNT(DISTINCT oi.order_id) >= 100
ORDER BY revenue_rank;

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-Time'
        WHEN total_orders BETWEEN 2 AND 3 THEN 'Repeat'
        ELSE 'Loyal'
    END AS customer_segment,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY customer_segment
ORDER BY customer_count DESC;


WITH seller_sales AS (
    SELECT
        s.seller_id,
        s.seller_state,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.price) AS total_revenue
    FROM sellers s
    JOIN order_items oi
        ON s.seller_id = oi.seller_id
    GROUP BY
        s.seller_id,
        s.seller_state
)
SELECT
    seller_id,
    seller_state,
    total_orders,
    total_revenue,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS seller_rank
FROM seller_sales
ORDER BY seller_rank
LIMIT 10;


WITH order_values AS (
    SELECT
        o.order_id,
        o.customer_id,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        o.customer_id
)
SELECT
    customer_id,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_spent,
    ROUND(AVG(order_value), 2) AS avg_order_value
FROM order_values
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;


SELECT
    p.product_category_name,
    COUNT(DISTINCT oi.product_id) AS total_products,
    SUM(oi.price) AS total_revenue,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT oi.order_id),
        2
    ) AS avg_order_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;


SELECT
    s.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY
    s.seller_id,
    s.seller_state
HAVING COUNT(DISTINCT oi.order_id) >= 50
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS avg_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY order_month
HAVING total_revenue > 100000
ORDER BY total_revenue DESC;


SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS avg_order_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;












