# Case Study-2 : Pizza Runner

## A. Pizza Metrics

## Queries with Output

[Check the Complete Query](https://github.com/Mahima012/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20%3A%20Pizza%20Runner/Pizza%20Runner.sql)

***
### 1). How many pizzas were ordered?'

````sql
SELECT COUNT(pizza_id) AS total_orders
FROM customer_orders_temp;
````

### Output:
|total_orders|
|------------|
|14          |

***
### 2). How many unique customer orders were made?

````sql
SELECT COUNT(DISTINCT order_id) AS unique_cust
FROM customer_orders_temp;
````

### Output:
|unique_cust |
|------------|
|10          |

***
### 3). How many successful orders were delivered by each runner?

````sql
SELECT runner_id
       ,COUNT(DISTINCT order_id) AS completed
FROM runner_orders_temp
WHERE pickup_time IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;
````

### Output:
|runner_id|completed  |
|---------|-----------|
|1        |4          |
|2        |3          |
|3        |1          |

***
### 4). How many of each type of pizza was delivered?

````sql
SELECT p.pizza_id
       ,p.pizza_name
       ,count(*) AS qty
FROM runner_orders_temp AS r
LEFT JOIN customer_orders_temp AS c
ON r.order_id = c.order_id
LEFT JOIN pizza_names AS p
ON c.pizza_id = p.pizza_id
WHERE r.pickup_time IS NOT NULL
GROUP BY 1,2;
````

### Output:
| pizza_id | pizza_name  | price |
|----------|-------------|-------|
| 1        | Meatlovers  | 9     |
| 2        | Vegetarian  | 3     |


***
### 5). How many Vegetarian and Meatlovers were ordered by each customer?

````sql
SELECT c.customer_id,
SUM(CASE WHEN c.pizza_id = 1 THEN 1 END) AS 'Meatlovers',
SUM(CASE WHEN c.pizza_id = 2 THEN 1 END) AS 'Vegetarian'
FROM runner_orders_temp AS r
LEFT JOIN customer_orders_temp AS c
ON r.order_id = c.order_id
LEFT JOIN pizza_names AS p
ON c.pizza_id = p.pizza_id
GROUP BY 1;
````

### Output:
| customer_id | meatlovers | vegeterian |
|-------------|------------|------------|
| 101         | 2          | 1          |
| 102         | 2          | 1          |
| 103         | 3          | 1          |
| 104         | 3          | 0          |
| 105         | 0          | 1          |


***
### 6). What was the maximum number of pizzas delivered in a single order?

````sql
SELECT customer_id
       ,order_id
       ,COUNT(pizza_id) as total_pizzas
FROM customer_orders_temp
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;
````

### Output
| customer_id | order_id | total_pizzas |
|-------------|----------|--------------|
| 103         | 4        | 3            |


***
### 7). For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
SELECT c.customer_id
       ,COUNT(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 END) AS changes
       ,COUNT(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 END) AS no_change
FROM customer_orders_temp AS c
LEFT JOIN runner_orders_temp AS r
ON r.order_id = c.order_id
WHERE r.pickup_time IS NOT NULL
GROUP BY 1
ORDER BY 1;
````

### Output:
| customer_id | changes | no_change |
|-------------|---------|-----------|
| 101         | 0       | 2         |
| 102         | 0       | 3         |
| 103         | 3       | 0         |
| 104         | 2       | 1         |
| 105         | 1       | 0         |


***
### 8). How many pizzas were delivered that had both exclusions and extras?

````sql
SELECT COUNT(pizza_id) AS pizza_having_exclusions_n_extras
FROM customer_orders_temp
WHERE exclusions IS NOT NULL  
AND extras IS NOT NULL;
````

### Output:
| pizza_having_exclusions_n_extras |
|----------------------------------|
| 2                                |


***
### 9). What was the total volume of pizzas ordered for each hour of the day?

````sql
SELECT EXTRACT(HOUR FROM order_time) AS hour_of_day
       ,COUNT(pizza_id) as orders
FROM customer_orders_temp
GROUP BY 1
ORDER BY 1;
````

### Output:
| hour_of_day | orders |
|-------------|--------|
| 11          | 1      |
| 13          | 3      |
| 18          | 3      |
| 19          | 1      |
| 21          | 3      |
| 23          | 3      |


***
### 10). What was the volume of orders for each day of the week?

````sql
SELECT  DAYOFWEEK(order_time)-1 AS week_day
       ,DAYNAME(order_time) AS day_name
       ,COUNT(pizza_id) as orders
FROM customer_orders_temp
GROUP BY 1,2
ORDER BY 1;
````
### Output:
| week_day | day_name   | orders |
|----------|------------|--------|
| 3        | Wednesday  | 5      |
| 4        | Thursday   | 3      |
| 5        | Friday     | 1      |
| 6        | Saturday   | 5      |

***

