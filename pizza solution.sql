create database dominos;
use dominos;
CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

 SELECT 
    *
FROM
    orders;
 
CREATE TABLE orders_details (
    order_datails_id INT NOT NULL,
    order_id INT NOT NULL,
    priza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_datails_id)
);
 
SELECT 
    *
FROM
    orders_details;
  
  alter table orders_details rename column priza_id to pizza_id;
  
--   Basic:
-- Retrieve the total number of orders placed.
  
   SELECT 
    COUNT(order_id) AS total_number_of_orders
FROM
    orders;
   
-- Calculate the total revenue generated from pizza sales.
 
SELECT 
    ROUND(SUM(p.price * o.quantity), 2) AS total_revenue
FROM
    pizzas AS p
        INNER JOIN
    orders_details AS o ON p.pizza_id = o.pizza_id;
  
  
-- Identify the highest-priced pizza.
SELECT 
    pt.name AS pizza_name, MAX(p.price) AS highest_priced_pizza
FROM
    pizza_types AS pt
        INNER JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY highest_priced_pizza DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(o.order_id) AS cnt
FROM
    pizzas AS p
        INNER JOIN
    orders_details AS o ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY cnt DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name AS name, SUM(o.quantity) AS qnt
FROM
    pizza_types AS pt
        INNER JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        INNER JOIN
    orders_details AS o ON p.pizza_id = o.pizza_id
GROUP BY pt.name
ORDER BY qnt DESC
LIMIT 5;


-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(o.quantity) AS qnt
FROM
    pizza_types AS pt
        INNER JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        INNER JOIN
    orders_details AS o ON p.pizza_id = o.pizza_id
GROUP BY pt.category
ORDER BY qnt DESC;

-- Determine the distribution of orders by hour of the day.

 SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS cnt
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY hours ASC;


-- Join relevant tables to find the category-wise distribution of pizzas
SELECT 
    category, COUNT(pizza_type_id) AS pizza
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(qnt), 2) AS avg_order_per_day
FROM
    (SELECT 
        r.order_date, SUM(quantity) AS qnt
    FROM
        orders AS r
    INNER JOIN orders_details AS o ON r.order_id = o.order_id
    GROUP BY r.order_date) a;
    
    
    
-- Determine the top 3 most ordered pizza types based on revenue. 

 SELECT 
    pt.pizza_type_id,
    pt.name,
    SUM(p.price * o.quantity) AS revenue
FROM
    pizza_types AS pt
        INNER JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        INNER JOIN
    orders_details AS o ON p.pizza_id = o.pizza_id
GROUP BY pt.pizza_type_id , pt.name
ORDER BY revenue DESC
LIMIT 3;
    
    
    
 -- Advanced:
--  Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    CONCAT(ROUND(SUM(p.price * o.quantity) / (SELECT 
                            ROUND(SUM(p.price * o.quantity), 2) AS total_revenue
                        FROM
                            pizzas AS p
                                INNER JOIN
                            orders_details AS o ON p.pizza_id = o.pizza_id) * 100,
                    2),
            '%') AS percent_contribution
FROM
    pizza_types AS pt
        INNER JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        INNER JOIN
    orders_details AS o ON p.pizza_id = o.pizza_id
GROUP BY pt.category
ORDER BY percent_contribution DESC;
    
    


-- Analyze the cumulative revenue generated over time.
with cte as(
select r.order_date ,round(sum(o.quantity*p.price),2)
  as revenue
 from orders as r
 inner join orders_details as o
 on r.order_id= o.order_id 
 inner join pizzas as p
 on o.pizza_id=p.pizza_id
 group by r.order_date)
   select *, round(
   sum(revenue) over(order by order_date),2)as cumulative_revenue
   from cte;
   
   
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


with cte as(
 select pt.category, pt.pizza_type_id, pt.name, sum(o.quantity*p.price) as revenue
  from pizza_types as pt
   inner join pizzas as p 
   on pt.pizza_type_id=p.pizza_type_id 
   inner join orders_details as o
   on p.pizza_id=o.pizza_id
   group by  pt.category, pt.pizza_type_id, pt.name)
   
   select category, pizza_type_id, name , revenue
   from(
    select *,
    row_number() over(partition by category order by revenue desc) as rn
    from cte)a
    where rn<=3;
 
 


