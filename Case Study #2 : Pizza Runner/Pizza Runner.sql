CREATE SCHEMA pizza_runner;

CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;

CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time TIMESTAMP,
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', NULL),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', NULL),
  (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', NULL);


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');


--Data Cleaning

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

-- CHALLENGE --

--A. PIZZA METRICS

--1) How many pizzas were ordered?
SELECT COUNT(pizza_id) AS total_orders
FROM customer_orders_temp;

--2) How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_cust
FROM customer_orders_temp;

--3) How many successful orders were delivered by each runner?
SELECT runner_id
       ,COUNT(DISTINCT order_id) AS completed
FROM runner_orders_temp
WHERE pickup_time IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

--4) How many of each type of pizza was delivered?
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

--5) How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id,
COALESCE(SUM(CASE WHEN c.pizza_id = 1 THEN 1 END),0) AS 'Meatlovers',
COALESCE(SUM(CASE WHEN c.pizza_id = 2 THEN 1 END),0) AS 'Vegetarian'
FROM runner_orders_temp AS r
LEFT JOIN customer_orders_temp AS c
ON r.order_id = c.order_id
LEFT JOIN pizza_names AS p
ON c.pizza_id = p.pizza_id
GROUP BY 1;

--6) What was the maximum number of pizzas delivered in a single order?
SELECT customer_id
       ,order_id
       ,COUNT(pizza_id) as total_pizza
FROM customer_orders_temp
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;

--7) For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT c.customer_id
       ,COUNT(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 END) AS changes
       ,COUNT(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 END) AS no_change
FROM customer_orders_temp AS c
LEFT JOIN runner_orders_temp AS r
ON r.order_id = c.order_id
WHERE r.pickup_time IS NOT NULL
GROUP BY 1
ORDER BY 1;

--8) How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(pizza_id) AS pizza_having_exclusions_n_extras
FROM customer_orders_temp
WHERE exclusions IS NOT NULL  
AND extras IS NOT NULL;

--9) What was the total volume of pizzas ordered for each hour of the day?
SELECT EXTRACT(HOUR FROM order_time) AS hour_of_day
       ,COUNT(pizza_id) as orders
FROM customer_orders_temp
GROUP BY 1
ORDER BY 1;

--10) What was the volume of orders for each day of the week?
SELECT  DAYOFWEEK(order_time)-1 AS week_day
       ,DAYNAME(order_time) AS day_name
       ,COUNT(pizza_id) as orders
FROM customer_orders_temp
GROUP BY 1,2
ORDER BY 1;




--B. RUNNER AND CUSTOMER EXPERIENCE
--1) How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT WEEK(registration_date,1)+1 AS weeks
       ,COUNT(*) AS registered_runner
FROM runners
GROUP BY 1
ORDER BY 1;

--2) What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT distinct runner_id
       ,ROUND(AVG(MINUTE(TIMEDIFF(c.order_time,r.pickup_time))),2) AS order_to_pickup
FROM runner_orders_temp AS r
LEFT JOIN customer_orders_temp AS c
ON r.order_id = c.order_id
WHERE r.pickup_time IS NOT NULL
GROUP BY 1
ORDER BY 1;

--3) Is there any relationship between the number of pizzas and how long the order takes to prepare?
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
       ,Round(AVG(Total_time),0) AS avg_time
FROM CTE 
GROUP BY 1;

--4) What was the average distance travelled for each customer?
SELECT c.customer_id as orders
       ,ROUND(AVG(distance),2) AS avg_dist
FROM runner_orders_temp AS r
LEFT JOIN customer_orders_temp AS c
ON r.order_id = c.order_id
WHERE r.pickup_time IS NOT NULL
GROUP BY 1;

--5) What was the difference between the longest and shortest delivery times for all orders?
SELECT max(duration) - min(duration) as delivery_timediff
FROM runner_orders_temp;

--6) What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT distinct runner_id
       ,order_id
	   ,ROUND( distance / (duration/60), 2) as avg_speed
FROM runner_orders_temp
WHERE pickup_time IS NOT NULL
ORDER BY 2;

--7) What is the successful delivery percentage for each runner?
SELECT runner_id
	   ,CAST(COUNT(pickup_time) / COUNT(runner_id) * 100 AS UNSIGNED) as success_del
FROM runner_orders_temp
GROUP BY 1
ORDER BY 1;



ALTER TABLE customer_orders_temp
ADD id INT AUTO_INCREMENT PRIMARY KEY;

-- extracting exlusions in separate rows
DROP TABLE IF EXISTS exclusions;
CREATE TABLE exclusions
(SELECT id
       ,order_id
       ,CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(c.exclusions, ',', n.toppings), ',', -1)) AS UNSIGNED) AS topping_id
FROM customer_orders_temp c
JOIN toppings n 
ON n.toppings <= 1 + LENGTH(c.exclusions) - LENGTH(REPLACE(c.exclusions, ',', ''))
WHERE c.exclusions IS NOT NULL);

-- extracting extras in separate rows
DROP TABLE IF EXISTS extras;
CREATE TABLE extras
(SELECT id
       ,order_id
       ,CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(c.extras, ',', n.toppings), ',', -1)) AS UNSIGNED) AS topping_id
FROM customer_orders_temp c
JOIN toppings n 
ON n.toppings <= 1 + LENGTH(c.extras) - LENGTH(REPLACE(c.extras, ',', ''))
WHERE c.extras IS NOT NULL);




--C. IBGREDIENTS OPTIMISATION
--1) What are the standard ingredients for each pizza?
SELECT t.pizza_id
       ,GROUP_CONCAT(topping_name ORDER BY pizza_id SEPARATOR ',') AS toppings
FROM pizza_recipes_temp AS t
LEFT JOIN pizza_toppings AS pt
ON t.toppings = pt.topping_id
GROUP BY 1;

--2) What was the most commonly added extra?
SELECT e.topping_id
       ,p.topping_name
       ,count(*) as total_addition
FROM extras AS e
LEFT JOIN pizza_toppings AS p
ON e.topping_id = p.topping_id
GROUP BY 1,2
ORDER BY COUNT(*) DESC
LIMIT 1;

--3) What was the most common exclusion?
SELECT e.topping_id
       ,p.topping_name
       ,count(*) AS total_excl
FROM exclusions AS e
LEFT JOIN pizza_toppings AS p
ON e.topping_id = p.topping_id
GROUP BY 1,2
ORDER BY COUNT(*) DESC
LIMIT 1;

/*4) Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/
WITH extra AS
(SELECT id,
        CONCAT('Extra ',GROUP_CONCAT(p.topping_name ORDER BY p.topping_name SEPARATOR ',')) AS toppings
FROM extras e
LEFT JOIN pizza_toppings p
ON e.topping_id = p.topping_id
GROUP BY 1)
,exclusion AS 
(SELECT id,
        CONCAT('Exclude ',GROUP_CONCAT(p.topping_name ORDER BY p.topping_name SEPARATOR ',')) AS toppings
FROM exclusions e
LEFT JOIN pizza_toppings p
ON e.topping_id = p.topping_id
GROUP BY 1)
,combined AS
(SELECT * FROM extra
UNION
SELECT * FROM exclusion)

SELECT c.id
	   ,c.order_id
	   ,CONCAT_WS(' - ', p.pizza_name, GROUP_CONCAT(cte.toppings SEPARATOR ' - ')) AS pizza_and_topping
FROM customer_orders_temp c
JOIN pizza_names p 
ON c.pizza_id = p.pizza_id 
LEFT JOIN combined cte 
ON c.id = cte.id
GROUP BY c.id,c.order_id,p.pizza_name
ORDER BY 1;

/*5) Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" */
WITH CTE AS
(SELECT c.id
	   ,c.order_id
       ,ps.pizza_name
       ,p.toppings
FROM customer_orders_temp c
LEFT JOIN pizza_recipes_temp p
ON c.pizza_id = p.pizza_id
LEFT JOIN pizza_names ps
ON c.pizza_id = ps.pizza_id
WHERE (c.id, c.order_id,toppings) NOT IN 
(SELECT id, order_id,topping_id FROM exclusions))

SELECT cte.id
      ,CONCAT_WS(': ', cte.pizza_name
					 ,GROUP_CONCAT(CASE WHEN (cte.id,cte.toppings) IN (SELECT id,topping_id FROM extras) 
										THEN CONCAT('2X ', p.topping_name)
                                   ELSE p.topping_name END ORDER BY p.topping_name SEPARATOR ', ')
				) AS pizza_toppings_description
FROM CTE 
LEFT JOIN pizza_toppings p
ON cte.toppings = p.topping_id
GROUP BY cte.id,cte.pizza_name
ORDER BY 1;

--6) What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
WITH CTE AS
(SELECT c.id
	   ,c.order_id
       ,p.toppings
FROM customer_orders_temp c
LEFT JOIN pizza_recipes_temp p
ON c.pizza_id = p.pizza_id
WHERE (c.id, c.order_id,toppings) NOT IN 
(SELECT id, order_id,topping_id FROM exclusions)
UNION ALL
SELECT * from extras)

SELECT p.topping_name
      ,count(*) AS total_additions
FROM CTE 
LEFT JOIN pizza_toppings p
ON cte.toppings = p.topping_id
LEFT JOIN runner_orders_temp r
ON cte.order_id = r.order_id
WHERE r.pickup_time IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;




--D. PRICING AND RATINGS
/*1) If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
     - how much money has Pizza Runner made so far if there are no delivery fees?*/
SELECT SUM(CASE WHEN c.pizza_id = 1 THEN 12 ELSE 10 END) AS charges
FROM runner_orders_temp r
LEFT JOIN customer_orders_temp c
ON r.order_id = c.order_id
WHERE r.pickup_time IS NOT NULL;
     
--2) What if there was an additional $1 charge for any pizza extras - Add cheese is $1 extra
SELECT SUM(CASE WHEN c.pizza_id = 1 AND extras = 4 THEN (12+1+1)
                WHEN c.pizza_id = 1 AND extras IS NOT NULL AND extras <> 4 THEN (12+1) ELSE 12 END) AS charges
FROM runner_orders_temp r
LEFT JOIN customer_orders_temp c
ON r.order_id = c.order_id
WHERE r.pickup_time IS NOT NULL;

/*3)The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner,
how would you design an additional table for this new dataset - generate a schema for this new table and insert your own
 data for ratings for each successful customer order between 1 to 5.*/
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

/*4) Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup, Delivery duration, Average speed, Total number of pizzas */
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

/*5) If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled 
     - how much money does Pizza Runner have left over after these deliveries?*/
SELECT ROUND(SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) -
       (select sum(distance)*0.3 from runner_orders_temp),2) AS profit
FROM customer_orders_temp c
LEFT JOIN runner_orders_temp r 
ON c.order_id = r.order_id
WHERE r.cancellation IS NULL;

