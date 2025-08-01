CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);


INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT * FROM sales;
SELECT * FROM menu;
SELECT * FROM members;


-- CHALLENGE --

-- 1. What is the total amount each customer spent at the restaurant? --
SELECT s.customer_id
       ,SUM(m.price) as total_amt
FROM sales AS s
LEFT JOIN menu AS m
ON S.product_id = M.product_id
GROUP BY s.customer_id;


-- 2. How many days has each customer visited the restaurant? --
SELECT customer_id
       ,count(distinct order_date) as days_visited
FROM sales
GROUP BY customer_id;


-- 3. What was the first item from the menu purchased by each customer? --
WITH cte AS
(SELECT s.customer_id
	   ,m.product_name
	   ,DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
FROM sales AS s
LEFT JOIN menu AS m
ON S.product_id = M.product_id
)

SELECT DISTINCT customer_id
       ,product_name
FROM cte
WHERE rn = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers? --
SELECT TOP 1 m.product_name
       ,count(s.product_id) as times_purchased
FROM menu as m
LEFT JOIN sales as s
ON m.product_id = s.product_id
GROUP BY m.product_name,m.product_id
ORDER BY 2 DESC;


-- 5. Which item was the most popular for each customer? --
WITH cte AS
(SELECT s.customer_id
       ,m.product_name
	   ,COUNT(*) AS time_purchased
	   ,DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rn
FROM sales AS s
LEFT JOIN menu AS m
ON S.product_id = M.product_id
GROUP BY s.customer_id,m.product_name
)
SELECT customer_id
       ,product_name
FROM cte
WHERE rn = 1;


-- 6. Which item was purchased first by the customer after they became a member?  --
WITH cte AS
(SELECT m.customer_id
       ,m.join_date
	   ,s.order_date
	   ,mu.product_name
	   ,DENSE_RANK() OVER (PARTITION BY m.customer_id ORDER BY s.order_date) AS rn
FROM members AS m
LEFT JOIN sales AS s
on m.customer_id = s.customer_id
AND s.order_date >= m.join_date 
LEFT JOIN menu as mu
ON s.product_id = mu.product_id)

SELECT customer_id
       ,product_name
FROM cte
WHERE rn = 1;


-- 7. Which item was purchased just before the customer became a member? --
WITH cte AS
(SELECT m.customer_id
       ,m.join_date
	   ,s.order_date
	   ,mu.product_name
	   ,DENSE_RANK() OVER (PARTITION BY m.customer_id ORDER BY s.order_date desc) AS rn
FROM members AS m
LEFT JOIN sales AS s
on m.customer_id = s.customer_id
AND s.order_date < m.join_date 
LEFT JOIN menu as mu
ON s.product_id = mu.product_id)

SELECT customer_id
       ,product_name
FROM cte
WHERE rn = 1;


-- 8. What is the total items and amount spent for each member before they became a member? --
SELECT s.customer_id
       ,COUNT(s.product_id) as total_items
	   ,SUM(mu.price) as total_amt
FROM sales AS s
LEFT JOIN members AS m
on s.customer_id = m.customer_id
LEFT JOIN menu as mu
ON s.product_id = mu.product_id
WHERE s.order_date < m.join_date 
GROUP BY s.customer_id;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? --
SELECT s.customer_id
       ,SUM (CASE WHEN s.product_id = 1 THEN (m.price * 10 *2) 
	              ELSE (m.price * 10) END )
		AS points
FROM sales AS s
LEFT JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--     not just sushi - how many points do customer A and B have at the end of January? --
SELECT m.customer_id,
      SUM (CASE WHEN s.product_id = 1 THEN (mu.price * 10 *2) 
	            WHEN s.product_id IN (2,3) AND s.order_date between m.join_date and DATEADD(DAY,6,m.join_date) THEN (mu.price * 10 *2) 
	            ELSE (mu.price * 10) END )
		AS points
FROM members AS m
LEFT JOIN sales as s
ON m.customer_id = s.customer_id
LEFT JOIN menu AS mu
ON s.product_id = mu.product_id
WHERE MONTH(s.order_date) = 1
GROUP BY m.customer_id;


