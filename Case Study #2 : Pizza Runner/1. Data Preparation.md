Data Cleaning - To ensure there are no anomalies in the data. Identifying and correcting errors, inconsistencies, and inaccuracies within a dataset. Key aspects include:

*** 

````sql
-- customer_orders
DROP TABLE IF EXISTS customer_orders_temp;
CREATE TABLE customer_orders_temp
(SELECT order_id
       ,customer_id
       ,pizza_id
       ,CASE WHEN exclusions = '' THEN null 
             WHEN exclusions = 'null' THEN null 
             ELSE exclusions END AS exclusions
       ,CASE WHEN extras = '' THEN null
             WHEN extras = 'null' THEN null 
             ELSE extras END AS extras
		,order_time
FROM customer_orders);
````

### Output:
| order_id | customer_id | pizza_id | exclusions | extras  | order_time           | order_item_id |
|----------|-------------|----------|------------|---------|----------------------|----------------|
| 1        | 101         | 1        | NULL       | NULL    | 2020-01-01 18:05:02  | 1              |
| 2        | 101         | 1        | NULL       | NULL    | 2020-01-01 19:00:52  | 2              |
| 3        | 102         | 1        | NULL       | NULL    | 2020-01-02 23:51:23  | 3              |
| 3        | 102         | 2        | NULL       | NULL    | 2020-01-02 23:51:23  | 4              |
| 4        | 103         | 1        | 4          | NULL    | 2020-01-04 13:23:46  | 5              |
| 4        | 103         | 1        | 4          | NULL    | 2020-01-04 13:23:46  | 6              |
| 4        | 103         | 2        | 4          | NULL    | 2020-01-04 13:23:46  | 7              |
| 5        | 104         | 1        | NULL       | 1       | 2020-01-08 21:00:29  | 8              |
| 6        | 101         | 2        | NULL       | NULL    | 2020-01-08 21:03:13  | 9              |
| 7        | 105         | 2        | NULL       | 1       | 2020-01-08 21:20:29  | 10             |
| 8        | 102         | 1        | NULL       | NULL    | 2020-01-09 23:54:33  | 11             |
| 9        | 103         | 1        | 4          | 1, 5    | 2020-01-10 11:22:59  | 12             |
| 10       | 104         | 1        | NULL       | NULL    | 2020-01-11 18:34:49  | 13             |
| 10       | 104         | 1        | 2, 6       | 1, 4    | 2020-01-11 18:34:49  | 14             |



***

````sql
-- runner_orders
DROP TABLE IF EXISTS runner_orders_temp;
CREATE TABLE runner_orders_temp
(SELECT order_id
       ,runner_id
       ,pickup_time
       ,CASE WHEN distance = 'null' THEN NULL
		     ELSE CAST(regexp_replace(distance, '[a-z]+', '') AS FLOAT)
             END AS distance
       ,CASE WHEN duration = 'null' THEN NULL
		     ELSE CAST(regexp_replace(duration, '[a-z]+', '') AS FLOAT)
             END AS duration
       ,CASE WHEN cancellation = '' THEN null
             WHEN cancellation = 'null' THEN null 
             ELSE cancellation END AS cancellation
FROM runner_orders);
````

### Output:
| order_id | runner_id | pickup_time          | distance | duration | cancellation             |
|----------|-----------|----------------------|----------|----------|---------------------------|
| 1        | 1         | 2020-01-01 18:15:34  | 20       | 32       | NULL                      |
| 2        | 1         | 2020-01-01 19:10:54  | 20       | 27       | NULL                      |
| 3        | 1         | 2020-01-03 00:12:37  | 13.4     | 20       | NULL                      |
| 4        | 2         | 2020-01-04 13:53:03  | 23.4     | 40       | NULL                      |
| 5        | 3         | 2020-01-08 21:10:57  | 10       | 15       | NULL                      |
| 6        | 3         | NULL                 | NULL     | NULL     | Restaurant Cancellation   |
| 7        | 2         | 2020-01-08 21:30:45  | 25       | 25       | NULL                      |
| 8        | 2         | 2020-01-10 00:15:02  | 23.4     | 15       | NULL                      |
| 9        | 2         | NULL                 | NULL     | NULL     | Customer Cancellation     |
| 10       | 1         | 2020-01-11 18:50:20  | 10       | 10       | NULL                      |

***

````sql
-- pizza_recipes

-- Step-1: creating a separate table to take out all the toppings in separate rows
DROP TABLE IF EXISTS toppings;
CREATE TABLE toppings(
SELECT topping_id as toppings FROM pizza_toppings
);

DROP TABLE IF EXISTS pizza_recipes_temp;
CREATE TABLE pizza_recipes_temp(
SELECT r.pizza_id
      ,TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(r.toppings, ',', t.toppings), ',', -1)) AS toppings
FROM pizza_recipes AS r
JOIN toppings t ON t.toppings <= 1 + LENGTH(r.toppings) - LENGTH(REPLACE(r.toppings, ',', ''))
ORDER BY r.pizza_id
         ,CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(r.toppings, ',', t.toppings), ',', -1)) AS UNSIGNED)
);
````

### Output:
| toppings  |
|-----------|
| 1         |
| 2         |
| 3         |
| 4         |
| 5         |
| 6         |
| 7         |
| 8         |
| 9         |
| 10        |
| 11        |
| 12        |

| pizza_id | toppings |
|----------|----------|
| 1        | 1        |
| 1        | 2        |
| 1        | 3        |
| 1        | 4        |
| 1        | 5        |
| 1        | 6        |
| 1        | 8        |
| 1        | 10       |
| 2        | 4        |
| 2        | 6        |
| 2        | 7        |
| 2        | 9        |
| 2        | 11       |
| 2        | 12       |

