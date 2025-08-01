# Case Study-2 : Pizza Runner

## C. Ingredient Optimisation

### Queries with Output

[Check the Complete Query](https://github.com/Mahima012/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20%3A%20Pizza%20Runner/Pizza%20Runner.sql)

***
### Created separate tables for exclusions and extras to extract the values in separate rows.

````sql
-- exclusions
DROP TABLE IF EXISTS exclusions;
CREATE TABLE exclusions
(SELECT id
       ,order_id
       ,CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(c.exclusions, ',', n.toppings), ',', -1)) AS UNSIGNED) AS topping_id
FROM customer_orders_temp c
JOIN toppings n 
ON n.toppings <= 1 + LENGTH(c.exclusions) - LENGTH(REPLACE(c.exclusions, ',', ''))
WHERE c.exclusions IS NOT NULL);
````

### Output:
| id  | order_id | topping_id |
|-----|----------|------------|
| 5   | 4        | 4          |
| 6   | 4        | 4          |
| 7   | 4        | 4          |
| 12  | 9        | 4          |
| 14  | 10       | 6          |
| 14  | 10       | 2          |


***

````sql
-- extras
DROP TABLE IF EXISTS extras;
CREATE TABLE extras
(SELECT id
       ,order_id
       ,CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(c.extras, ',', n.toppings), ',', -1)) AS UNSIGNED) AS topping_id
FROM customer_orders_temp c
JOIN toppings n 
ON n.toppings <= 1 + LENGTH(c.extras) - LENGTH(REPLACE(c.extras, ',', ''))
WHERE c.extras IS NOT NULL);
````

### Output:
| id  | order_id | topping_id |
|-----|----------|------------|
| 8   | 5        | 1          |
| 10  | 7        | 1          |
| 12  | 9        | 5          |
| 12  | 9        | 1          |
| 14  | 10       | 4          |
| 14  | 10       | 1          |

***
### 1). What are the standard ingredients for each pizza?

````sql
SELECT t.pizza_id
       ,GROUP_CONCAT(topping_name ORDER BY pizza_id SEPARATOR ',') AS toppings
FROM pizza_recipes_temp AS t
LEFT JOIN pizza_toppings AS pt
ON t.toppings = pt.topping_id
GROUP BY 1;
````

### Output:
| pizza_id | toppings                                                                  |
|----------|---------------------------------------------------------------------------|
| 1        | Salami, Pepperoni, Mushrooms, Chicken, Cheese, Beef, BBQ Sauce, Bacon     |
| 2        | Tomato Sauce, Tomatoes, Peppers, Onions, Mushrooms, Cheese                |

***
### 2). What was the most commonly added extra?

````sql
SELECT e.topping_id
       ,p.topping_name
       ,count(*) as total_addition
FROM extras AS e
LEFT JOIN pizza_toppings AS p
ON e.topping_id = p.topping_id
GROUP BY 1,2
ORDER BY COUNT(*) DESC
LIMIT 1;
````

### Output:
| topping_id | topping_name | total_addition |
|------------|--------------|----------------|
| 1          | Bacon        | 4              |

***
### 3). What was the most common exclusion?

````sql
SELECT e.topping_id
       ,p.topping_name
       ,count(*) AS total_excl
FROM exclusions AS e
LEFT JOIN pizza_toppings AS p
ON e.topping_id = p.topping_id
GROUP BY 1,2
ORDER BY COUNT(*) DESC
LIMIT 1;
````

### Output:
| topping_id | topping_name | total_excl |
|------------|--------------|------------|
| 4          | Cheese       | 4          |

***
### 4). Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/

````sql
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
````

### Output:
| id  | order_id | pizza_and_topping                                        |
|-----|----------|----------------------------------------------------------|
| 1   | 1        | Meatlovers                                               |
| 2   | 2        | Meatlovers                                               |
| 3   | 3        | Meatlovers                                               |
| 4   | 3        | Vegetarian                                               |
| 5   | 4        | Meatlovers - Exclude Cheese                              |
| 6   | 4        | Meatlovers - Exclude Cheese                              |
| 7   | 4        | Vegetarian - Exclude Cheese                              |
| 8   | 5        | Meatlovers - Extra Bacon                                 |
| 9   | 6        | Vegetarian                                               |
| 10  | 7        | Vegetarian - Extra Bacon                                 |
| 11  | 8        | Meatlovers                                               |
| 12  | 9        | Meatlovers - Extra Bacon, Chicken - Exclude Cheese       |
| 13  | 10       | Meatlovers                                               |
| 14  | 10       | Meatlovers - Extra Bacon, Cheese - Exclude BBQ Sauce, Mushrooms |

***
### 5). Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" */

````sql
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
````

### Output:
| id  | pizza_toppings_description                                                                 |
|-----|--------------------------------------------------------------------------------------------|
| 1   | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami          |
| 2   | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami          |
| 3   | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami          |
| 4   | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                     |
| 5   | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami                  |
| 6   | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami                  |
| 7   | Vegetarian: Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                             |
| 8   | Meatlovers: 2X Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami       |
| 9   | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                     |
| 10  | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                     |
| 11  | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami          |
| 12  | Meatlovers: 2X Bacon, BBQ Sauce, Beef, 2X Chicken, Mushrooms, Pepperoni, Salami            |
| 13  | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami          |
| 14  | Meatlovers: 2X Bacon, Beef, 2X Cheese, Chicken, Pepperoni, Salami                          |

***
### 6). What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

````sql
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
````

### Output:
| topping_name   | total_additions |
|----------------|-----------------|
| Bacon          | 12              |
| Mushrooms      | 11              |
| Cheese         | 10              |
| Salami         | 9               |
| Pepperoni      | 9               |
| Chicken        | 9               |
| Beef           | 9               |
| BBQ Sauce      | 8               |
| Tomato Sauce   | 3               |
| Tomatoes       | 3               |
| Peppers        | 3               |
| Onions         | 3               |

***
