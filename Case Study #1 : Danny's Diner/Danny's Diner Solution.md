# Case Study-1 : Danny's Diner

## Queries with Ouput

[Check the Complete Query](https://github.com/Mahima012/8-Week-SQL-Challenge/blob/main/Danny's%20Diner.sql)

*** 
### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT s.customer_id
       ,SUM(m.price) as total_amt
FROM sales AS s
LEFT JOIN menu AS m
ON S.product_id = M.product_id
GROUP BY s.customer_id;
````

### Output:
|customer_id|total_amt|
|-----------|---------|
|A          |76       |
|B          |74       |
|C          |36       |

***

### 2. How many days has each customer visited the restaurant? 

````sql
SELECT customer_id
       ,count(distinct order_date) as days_visited
FROM sales
GROUP BY customer_id;
````

### Output:
|customer_id|days_visited|
|-----------|------------|
|A          |4           |
|B          |6           |
|C          |2           |

***

### 3. What was the first item from the menu purchased by each customer?

````sql
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
WHERE rn = 1
````

### Output:
|customer_id|product_name|
|-----------|------------|
|A          |curry       |
|A          |sushi       |
|B          |curry       |
|C          |ramen       |

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT TOP 1 m.product_name
       ,count(s.product_id) as times_purchased
FROM menu as m
LEFT JOIN sales as s
ON m.product_id = s.product_id
GROUP BY m.product_name,m.product_id
ORDER BY 2 DESC
````

### Output:
|product_name|times_purchased|
|------------|---------------|
|ramen       |8              |

***

### 5. Which item was the most popular for each customer?

````sql
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
WHERE rn = 1
````

### Output:
|customer_id|product_name|
|-----------|------------|
|A          |ramen       |
|B          |sushi       |
|B          |curry       |
|B          |ramen       |
|C          |ramen       |

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
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
WHERE rn = 1
````

### Output:
|customer_id|product_name|
|-----------|------------|
|A          |curry       |
|B          |sushi       |

***
### 7. Which item was purchased just before the customer became a member?

````sql
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
WHERE rn = 1
````

### Output:
|customer_id|product_name|
|-----------|------------|
|A          |sushi       |
|A          |curry       |
|B          |sushi       |

***
### 8. What is the total items and amount spent for each member before they became a member?

````sql
SELECT s.customer_id
       ,COUNT(s.product_id) as total_items
	   ,SUM(mu.price) as total_amt
FROM sales AS s
LEFT JOIN members AS m
on s.customer_id = m.customer_id
LEFT JOIN menu as mu
ON s.product_id = mu.product_id
WHERE s.order_date < m.join_date 
GROUP BY s.customer_id
````

### Output:
|customer_id|total_items|total_amt|
|-----------|-----------|---------|
|A          |2          |25       |
|B          |3          |40       |

***
###  9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

````sql
SELECT s.customer_id
       ,SUM (CASE WHEN s.product_id = 1 THEN (m.price * 10 *2) 
	              ELSE (m.price * 10) END )
		AS points
FROM sales AS s
LEFT JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id
````

### Output:
|customer_id|points      |
|-----------|------------|
|A          |860         |
|A          |940         |
|B          |360         |

***
### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

````sql
SELECT m.customer_id
       ,SUM (CASE WHEN s.product_id = 1 THEN (mu.price * 10 *2) 
	            WHEN s.product_id IN (2,3) AND s.order_date between m.join_date and DATEADD(DAY,6,m.join_date) 
                    THEN (mu.price * 10 *2) 
	            ELSE (mu.price * 10) END )
		AS points
FROM members AS m
LEFT JOIN sales as s
ON m.customer_id = s.customer_id
LEFT JOIN menu AS mu
ON s.product_id = mu.product_id
WHERE MONTH(s.order_date) = 1
GROUP BY m.customer_id
````

### Output:
|customer_id|points      |
|-----------|------------|
|A          |1370        |
|A          |820         |

***
