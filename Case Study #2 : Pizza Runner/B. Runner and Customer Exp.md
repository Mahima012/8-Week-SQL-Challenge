# Case Study-2 : Pizza Runner

## B. Runner and Customer Experience

### Queries with Output

[Check the Complete Query](https://github.com/Mahima012/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20%3A%20Pizza%20Runner/Pizza%20Runner.sql)

***
### 1). How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)?

````sql
SELECT WEEK(registration_date,1)+1 AS weeks
       ,COUNT(*) AS registered_runner
FROM runners
GROUP BY 1
ORDER BY 1;
````

#### Output:
| weeks | registered_runners |
|-------|--------------------|
| 1     | 2                  |
| 2     | 1                  |
| 3     | 1                  |

***
### 2). What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
SELECT distinct runner_id
       ,ROUND(AVG(MINUTE(TIMEDIFF(c.order_time,r.pickup_time))),2) AS order_to_pickup
FROM runner_orders_temp AS r
LEFT JOIN customer_orders_temp AS c
ON r.order_id = c.order_id
WHERE r.pickup_time IS NOT NULL
GROUP BY 1
ORDER BY 1;
````

#### Output:
| runner_id | order_to_pickup |
|-----------|------------------|
| 1         | 15.33            |
| 2         | 23.40            |
| 3         | 10.00            |

***
### 3). Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
WITH CTE AS
(SELECT c.order_id as orders
       ,COUNT(c.order_id) as pizzas
       ,ROUND(MINUTE(TIMEDIFF(c.order_time,r.pickup_time)),0) AS total_time
FROM runner_orders_temp AS r
LEFT JOIN customer_orders_temp AS c
ON r.order_id = c.order_id
WHERE r.pickup_time IS NOT NULL
GROUP BY 1,3)

SELECT pizzas
       ,ROUND(AVG(Total_time),2) AS avg_time
FROM CTE 
GROUP BY 1;
````

#### Output:
| pizzas | avg_time |
|--------|----------|
| 1      | 12       |
| 2      | 18       |
| 3      | 29       |

Yes there's a direct relation between number of pizzas and time taken to prepare as with the more
number of pizza time taken to order is also more.

***
### 4). What was the average distance travelled for each customer?

````sql
SELECT c.customer_id as orders
       ,ROUND(AVG(distance),2) AS avg_dist
FROM runner_orders_temp AS r
LEFT JOIN customer_orders_temp AS c
ON r.order_id = c.order_id
WHERE r.pickup_time IS NOT NULL
GROUP BY 1;
````

#### Output:
| orders | avg_dist |
|--------|----------|
| 101    | 20       |
| 102    | 16.73    |
| 103    | 23.4     |
| 104    | 10       |
| 105    | 25       |

***
### 5). What was the difference between the longest and shortest delivery times for all orders?

````sql
SELECT max(duration) - min(duration) as delivery_timediff
FROM runner_orders_temp;
````

#### Output:
| delivery_timediff |
|-------------------|
| 30                |

***
### 6). What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
SELECT distinct runner_id
       ,order_id
	   ,ROUND( distance / (duration/60), 2) as avg_speed
FROM runner_orders_temp
WHERE pickup_time IS NOT NULL
ORDER BY 2;
````

#### Output:
| runner_id | order_id | avg_speed |
|-----------|----------|-----------|
| 1         | 1        | 37.5      |
| 1         | 2        | 44.44     |
| 1         | 3        | 40.2      |
| 2         | 4        | 35.1      |
| 3         | 5        | 40        |
| 2         | 7        | 60        |
| 2         | 8        | 93.6      |
| 1         | 10       | 60        |


***
### 7). What is the successful delivery percentage for each runner?

````sql
SELECT runner_id
	   ,CAST(COUNT(pickup_time) / COUNT(runner_id) * 100 AS UNSIGNED) as success_del
FROM runner_orders_temp
GROUP BY 1
ORDER BY 1;
````

#### Output:
| runner_id | success_del |
|-----------|-------------|
| 1         | 100         |
| 2         | 75          |
| 3         | 50          |

***
