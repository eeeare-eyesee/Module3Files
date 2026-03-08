USE coffeeshop_db;

-- =========================================================
-- SUBQUERIES & NESTED LOGIC PRACTICE
-- =========================================================

-- Q1) Scalar subquery (AVG benchmark):
--     List products priced above the overall average product price.
--     Return product_id, name, price.
select
product_id
,name
,price
from products
where price > 
	(select avg(price) from products);
    


-- Q2) Scalar subquery (MAX within category):
--     Find the most expensive product(s) in the 'Beans' category.
--     (Return all ties if more than one product shares the max price.)
--     Return product_id, name, price.

select
p.product_id
,p.name
,p.price
,c.name
from products p 
inner join categories c on p.category_id = c.category_id and c.name = 'Beans'
WHERE p.price = (
	select MAX(p2.price)
    from products p2 
    inner join categories c2 on c2.category_id = p2.category_id and c2.name = 'Beans');

 

-- Q3) List subquery (IN with nested lookup):
--     List customers who have purchased at least one product in the 'Merch' category.
--     Return customer_id, first_name, last_name.
--     Hint: Use a subquery to find the category_id for 'Merch', then a subquery to find product_ids.

select 
c.customer_id
,c.first_name
,c.last_name
-- ,oi.product_id
-- ,p.product_id
-- ,p.category_id
-- ,cat.category_id
-- ,cat.name
from customers c 
inner join orders o on c.customer_id = o.order_id
inner join order_items oi on o.order_id = oi.order_id
inner join products p on p.product_id = oi.product_id
inner join categories cat on p.category_id = cat.category_id and cat.name = 'Merch'




-- Q4) List subquery (NOT IN / anti-join logic):
--     List products that have never been ordered (their product_id never appears in order_items).
--     Return product_id, name, price.

select
product_id
,name
,price
from products 
where product_ID NOT IN (
select 
oi.product_id
from orders o 
inner join order_items oi on o.order_id = oi.order_id
where oi.product_id IS NOT NULL)

-- Q5) Table subquery (derived table + compare to overall average):
--     Build a derived table that computes total_units_sold per product
--     (SUM(order_items.quantity) grouped by product_id).
--     Then return only products whose total_units_sold is greater than the
--     average total_units_sold across all products.
--     Return product_id, product_name, total_units_sold.


SELECT*
FROM (select 
oi.product_id
,SUM(oi.quantity) as units_sold
from order_items oi
group by oi.product_id) AS tus_query
inner join products p on tus_query.product_id = p.product_id
where tus_query.units_sold > (
SELECT 
AVG(units_sold)
from (
select
 SUM(quantity) as units_sold
 from order_items
 group by product_id) as avg_units_sold

);

