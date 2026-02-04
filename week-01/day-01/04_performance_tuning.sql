-- index untuk foreign key
create index idx_orders_product_id on orders(product_id);
create index idx_orders_status on orders(status);
create index idx_orders_order_date on orders(order_date);
create index idx_products_category on products(category);
create index idx_products_price on products(price);


-- composite index untuk query yang sering digunakan bersama
create index idx_orders_status_date on orders(status, order_date);

=======================================================
-- query untuk dianalsis
explain analyze
select
	p.product_name,
	count(o.order_id) as total_orders
from products p
left join orders o on p.product_id = o.product_id
where o.status = 'completed'
group by p.product_id, p.product_name;

-- bandingkan dengan query tanpa kondisi
explain analyze
select
	p.product_name,
	count(o.order_id) as total_orders
from products p
left join orders o on p.product_id = o.product_id
group by p.product_id, p.product_name;
	
-- query dengan WHERE complex
explain analyze
select * 
from orders
where order_date between '2024-01-15' and '2024-01-20'
and status = 'completed'
and total_amount > 100;