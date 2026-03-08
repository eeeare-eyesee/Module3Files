USE coffeeshop_db;

-- =========================================================
-- ADVANCED SQL ASSIGNMENT
-- Subqueries, CTEs, Window Functions, Views
-- =========================================================
-- Notes:
-- - Unless a question says otherwise, use orders with status = 'paid'.
-- - Write ONE query per prompt.
-- - Keep results readable (use clear aliases, ORDER BY where it helps).

-- =========================================================
-- Q1) Correlated subquery: Above-average order totals (PAID only)
-- =========================================================
-- For each PAID order, compute order_total (= SUM(quantity * products.price)).
-- Return: order_id, customer_name, store_name, order_datetime, order_total.
-- Filter to orders where order_total is greater than the average PAID order_total
-- for THAT SAME store (correlated subquery).
-- Sort by store_name, then order_total DESC.

Select
OT.order_id
,c.First_name
,c.Last_name

from customers c 
inner join stores s on OT.store_id = s.store_id
(select
o.order_id
,o.store_id
,sum(oi.quantity*p.price) as order_total
from order_items oi 
inner join products p on oi.product_id = p.product_id
inner join orders o on o.order_id = oi.order_id
where o.status = 'Paid'
group by o.order_id) AS OT ;




-- =========================================================
-- Q2) CTE: Daily revenue and 3-day rolling average (PAID only)
-- =========================================================
-- Using a CTE, compute daily revenue per store:
--   revenue_day = SUM(quantity * products.price) grouped by store_id and DATE(order_datetime).
-- Then, for each store and date, return:
--   store_name, order_date, revenue_day,
--   rolling_3day_avg = average of revenue_day over the current day and the prior 2 days.
-- Use a window function for the rolling average.
-- Sort by store_name, order_date.




WITH t as (select 
o.order_id
,p.category_id
,DAYOFWEEK(o.order_datetime) as dow
,DAYNAME(o.order_datetime) as Order_Day
,SUM(oi.quantity*p.price) as total_rev

from orders o 
inner join order_items oi on o.order_id= oi.order_id
inner join products p on oi.product_id = p.product_id
group by o.order_id
order by dow asc)

Select 
t.*
,c.name
from t
inner join categories c on t.category_id = c.category_id



-- =========================================================
-- Q3) Window function: Rank customers by lifetime spend (PAID only)
-- =========================================================
-- Compute each customer's total spend across ALL stores (PAID only).
-- Return: customer_id, customer_name, total_spend,
--         spend_rank (DENSE_RANK by total_spend DESC).
-- Also include percent_of_total = customer's total_spend / total spend of all customers.
-- Sort by total_spend DESC.

select
c.customer_id
,c.first_name
,c.last_name
,t.tot_spend
,DENSE_RANK() OVER (PARTITION BY t.customer_id order by t.tot_spend) as spend_rank
from customers c 
left join (select
o.customer_id
,SUM(oi.quantity*p.price) as tot_spend

from orders o 
left join order_items oi on o.order_id = oi.order_id
left join products p on oi.product_id = oi.product_id 
group by o.customer_id) as t on t.customer_id = c.customer_id;




-- =========================================================
-- Q4) CTE + window: Top product per store by revenue (PAID only)
-- =========================================================
-- For each store, find the top-selling product by REVENUE (not units).
-- Revenue per product per store = SUM(quantity * products.price).
-- Return: store_name, product_name, category_name, product_revenue.
-- Use a CTE to compute product_revenue, then a window function (ROW_NUMBER)
-- partitioned by store to select the top 1.
-- Sort by store_name.

select
s.name
,t.name
,t.tot_rev
,ROW_NUMBER() over (partition by s.name order by t.tot_rev desc) as p_rev
from stores s 
left join (select
o.store_id
,o.status
,p.name
,SUM(oi.quantity*p.price) as tot_rev
from orders o 
left join order_items oi on o.order_id = oi.order_id
left join products p on oi.product_id = oi.product_id
group by o.store_id,p.name
order by o.store_id asc, tot_rev desc) as t on t.store_id = s.store_id
where 1=1
and t.status = 'Paid'
and p_rev = 1;




-- =========================================================
-- Q5) Subquery: Customers who have ordered from ALL stores (PAID only)
-- =========================================================
-- Return customers who have at least one PAID order in every store in the stores table.
-- Return: customer_id, customer_name.
-- Hint: Compare count(distinct store_id) per customer to (select count(*) from stores).


-- when I run this I see store_id = 6 does not have any orders on it. Should i assume that no customer would appear for this since orders do not appear for all stores?

select
s.store_id
,s.name
,o.order_id
from stores s 
left join orders o on s.store_id = o.store_id;


select *
from orders;


-- =========================================================
-- Q6) Window function: Time between orders per customer (PAID only)
-- =========================================================
-- For each customer, list their PAID orders in chronological order and compute:
--   prev_order_datetime (LAG),
--   minutes_since_prev (difference in minutes between current and previous order).
-- Return: customer_name, order_id, order_datetime, prev_order_datetime, minutes_since_prev.
-- Only show rows where prev_order_datetime is NOT NULL.
-- Sort by customer_name, order_datetime.

select 
c.first_name
,c.last_name
,t.order_datetime
,t.prev_order_datetime
,(t.order_datetime - t.prev_order_datetime) as minutes_since_prev

from customers c 
left join (
select
order_id
,customer_id
,order_datetime
,LAG(order_datetime) over (partition by customer_id order by order_datetime) as prev_order_datetime
from orders o
where o.status = 'paid' 
order by o.customer_id asc,o.order_datetime desc) as t on t.customer_id = c.customer_id;
-- where t.prev_order_datetime =1


-- =========================================================
-- Q7) View: Create a reusable order line view for PAID orders
-- =========================================================
-- Create a view named v_paid_order_lines that returns one row per PAID order item:
--   order_id, order_datetime, store_id, store_name,
--   customer_id, customer_name,
--   product_id, product_name, category_name,
--   quantity, unit_price (= products.price),
--   line_total (= quantity * products.price)
--
-- After creating the view, write a SELECT that uses the view to return:
--   store_name, category_name, revenue
-- where revenue is SUM(line_total),
-- sorted by revenue DESC.

CREATE VIEW v_paid_order_lines AS
SELECT
o.order_id
,o.order_datetime
,s.store_id
,s.name as store_name
,s.city
,s.state
,c.customer_id
,c.first_name
,c.last_name
,p.product_id
,p.name as product_name
,p.price as product_price
,cat.category_id
,cat.name as category_name
,(oi.quantity * p.price) as line_total
from orders o 
inner join stores s on o.store_id = s.store_id
inner join customers c on o.customer_id = c.customer_id
inner join order_items oi on o.order_id = oi.order_id
inner join products p on oi.product_id = p.product_id
inner join categories cat on p.category_id = cat.category_id
where o.status = 'paid';

select 
store_name
,category_name
,SUM(line_total) as rev
from v_paid_order_lines
group by store_name,category_name
order by rev desc;






-- =========================================================
-- Q8) View + window: Store revenue share by payment method (PAID only)
-- =========================================================
-- Create a view named v_paid_store_payments with:
--   store_id, store_name, payment_method, revenue
-- where revenue is total PAID revenue for that store/payment_method.
--
-- Then query the view to return:
--   store_name, payment_method, revenue,
--   store_total_revenue (window SUM over store),
--   pct_of_store_revenue (= revenue / store_total_revenue)
-- Sort by store_name, revenue DESC.

create view v_paid_store_payments as
select
o.store_id
,s.name as store_name
,o.payment_method
,SUM(oi.quantity * p.price) as rev
from orders o 
inner join stores s on s.store_id = o.store_id
inner join order_items oi o.order_id = oi.order_id
inner join products p on p.product_id = oi.product_id
where o.status = 'paid'
group by o.store_id, o.store_name,o.payment_method;

select
store_name
,payment_method
,rev
from v_paid_store_payments
order by storename desc,rev desc;




-- =========================================================
-- Q9) CTE: Inventory risk report (low stock relative to sales)
-- =========================================================
-- Identify items where on_hand is low compared to recent demand:
-- Using a CTE, compute total_units_sold per store/product for PAID orders.
-- Then join inventory to that result and return rows where:
--   on_hand < total_units_sold
-- Return: store_name, product_name, on_hand, total_units_sold, units_gap (= total_units_sold - on_hand)
-- Sort by units_gap DESC.


WITH t as (
select 
o.store_id
,oi.product_id
,SUM(oi.quantity) as total_units_sold
from orders o 
inner join order_items oi on o.order_id = oi.order_id
where o.status = 'paid'
group by o.store_id,oi.product_id)

select
s.name
,p.name as product_name
,i.on_hand
,t.total_units_sold
,(t.total_units_sold - i.on_hand) as unitsgap
from inventory i
inner join t on i.store_id  = t.store_id
inner join stores s on s.store_id = i.store_id
inner join products p on i.product_id = p.product_id
where i.on_hand< t.total_units_sold
order by unitsgap desc



