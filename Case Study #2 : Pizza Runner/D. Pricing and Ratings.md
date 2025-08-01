# Case Study-2 : Pizza Runner

## D. Pricing and Ratings

### Queries with Output

[Complete Query Snippet](https://github.com/Mahima012/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20%3A%20Pizza%20Runner/Pizza%20Runner.sql)

***
### 1). If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes. How much money has Pizza Runner made so far if there are no delivery fees?

````sql
SELECT SUM(CASE WHEN c.pizza_id = 1 THEN 12 ELSE 10 END) AS charges
FROM runner_orders_temp r
LEFT JOIN customer_orders_temp c
ON r.order_id = c.order_id
WHERE r.pickup_time IS NOT NULL;
````

#### Output:
| charges |
|---------|
| 138     |

***
### 2). What if there was an additional $1 charge for any pizza extras - Add cheese is $1 extras.

````sql
SELECT SUM(CASE WHEN c.pizza_id = 1 AND extras = 4 THEN (12+1+1)
                WHEN c.pizza_id = 1 AND extras IS NOT NULL AND extras <> 4 THEN (12+1) ELSE 12 END) AS charges
FROM runner_orders_temp r
LEFT JOIN customer_orders_temp c
ON r.order_id = c.order_id
WHERE r.pickup_time IS NOT NULL;
````

#### Output:
| charges |
|---------|
| 146     |

***
### 3).The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset 
- generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

````sql
#logic to create a rating mechanism
SELECT order_id
	   ,distance
       ,duration
       ,ROUND(distance/duration,2) as time_taken
       ,CASE WHEN ROUND(distance/duration,2) < 1 THEN 1
             WHEN ROUND(distance/duration,2) = 1 THEN 2
             WHEN ROUND(distance/duration,2) > 1 and ROUND(distance/duration,2) <1.5 THEN 3
             WHEN ROUND(distance/duration,2) > 1.5 and ROUND(distance/duration,2) <2 THEN 4
             ELSE 5 END AS ratings
FROM runner_orders_temp
WHERE pickup_time IS NOT NULL
ORDER BY 1; 

DROP TABLE IF EXISTS ratings;

CREATE TABLE ratings
(order_id INTEGER,
ratings INTEGER)

INSERT INTO ratings
VALUES (1,4),
       (2,3),
       (3,4),
       (4,5),
       (5,4),
       (7,2),
       (8,2),
       (10,1)
       
SELECT * FROM ratings;
````

#### Output:
| order_id | ratings |
|----------|---------|
|    1     |    4    |
|    2     |    3    |
|    3     |    4    |
|    4     |    5    |
|    5     |    4    |
|    7     |    2    |
|    8     |    2    |
|   10     |    1    |

***
### 4). Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries-
customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup, Delivery duration, Average speed, Total number of pizzas.

````sql
SELECT c.customer_id
       ,c.order_id
       ,r.runner_id
       ,rr.ratings
	   ,c.order_time
	   ,r.pickup_time
       ,MINUTE(TIMEDIFF(c.order_time,r.pickup_time)) AS time_to_pickup
       ,r.duration
       ,round(r.distance*60/r.duration, 2) AS average_speed
       ,count(c.pizza_id) AS total_pizzas
FROM customer_orders_temp AS c
LEFT JOIN runner_orders_temp AS r
ON c.order_id = r.order_id
LEFT JOIN ratings AS rr
ON c.order_id = rr.order_id
WHERE pickup_time IS NOT NULL
GROUP BY 1,2,3,4,5,6,7,8,9;
````

#### Output:
| customer_id | order_id | runner_id | ratings |     order_time      |    pickup_time     | time_to_pickup (min) | duration (min) | average_speed | total_pizzas |
|-------------|----------|-----------|---------|----------------------|---------------------|-----------------------|----------------|----------------|---------------|
|     101     |    1     |     1     |    4    | 2020-01-01 18:05:02  | 2020-01-01 18:15:34 |          10           |       32       |     37.5       |       1       |
|     101     |    2     |     1     |    3    | 2020-01-01 19:00:52  | 2020-01-01 19:10:54 |          10           |       27       |     44.44      |       1       |
|     102     |    3     |     1     |    4    | 2020-01-02 23:51:23  | 2020-01-03 00:12:37 |          21           |       20       |     40.2       |       2       |
|     103     |    4     |     2     |    5    | 2020-01-04 13:23:46  | 2020-01-04 13:53:03 |          29           |       40       |     35.1       |       3       |
|     104     |    5     |     3     |    4    | 2020-01-08 21:00:29  | 2020-01-08 21:10:57 |          10           |       15       |     40         |       1       |
|     105     |    7     |     2     |    2    | 2020-01-08 21:20:29  | 2020-01-08 21:30:45 |          10           |       25       |     60         |       1       |
|     102     |    8     |     2     |    2    | 2020-01-09 23:54:33  | 2020-01-10 00:15:02 |          20           |       15       |     93.6       |       1       |
|     104     |   10     |     1     |    1    | 2020-01-11 18:34:49  | 2020-01-11 18:50:20 |          15           |       10       |     60         |       2       |

***
### 5). If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometers travelled. 
- how much money does Pizza Runner have left over after these deliveries?

````sql
SELECT ROUND(SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) -
       (select sum(distance)*0.3 from runner_orders_temp),2) AS profit
FROM customer_orders_temp c
LEFT JOIN runner_orders_temp r 
ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
````

#### Output:
| profit  |
|---------|
| 94.4    |

***
