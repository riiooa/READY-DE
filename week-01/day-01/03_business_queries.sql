
select * from products
select * from orders;


select * from products where category = 'Electronics';

select product_name, price from products where price > 100;

select * from products order by price desc;

select * from orders order by order_date asc, total_amount desc;

update products set stock_quantity = stock_quantity - 2 where product_id = 2;

-- delete from orders where status = 'cancalled';

=======================================

-- Total penjualan per produk
select
	p.product_name,
	p.category,
	count(o.order_id) as total_order,
	sum(o.quantity) as total_quantity_sold,
	sum(o.total_amount) as total_revenue
from products p
left join orders o on p.product_id = o.product_id
where o.status = 'completed' or o.status is null
group by p.product_id, p.product_name, p.category
order by total_revenue desc nulls last;

-- product yang belum pernah terjual
select
	p.product_id,
	p.product_name,
	p.category,
	p.price
from products p
left join orders o on p.product_id = o.product_id
where o.order_id is null


-- rata-rata nilai transaksi per kategori
select
	p.category,
	count(distinct o.order_id) as order_count,
	avg(o.total_amount) as avg_order_value,
	sum(o.total_amount) as category_revenue
from orders o
inner join products p on o.product_id = p.product_id
where o.status = 'completed'
group by p.category
order by category_revenue desc;

-- top 5 produk terlaris
select
	p.product_name,
	sum(o.quantity) as total_sold,
	sum(o.total_amount) as revenue
from orders o
join products p on o.product_id = p.product_id
where o.status = 'completed'
group by p.product_id, p.product_name 
order by total_sold desc
limit 5;

-- penjualan harian
select
	order_date,
	count(order_id) as daily_orders,
	sum(total_amount) as daily_revenue
from orders 
where status = 'completed'
group by order_date
order by order_date desc;

-- pelanggan dengan transaksi terbanyak
select
	customer_name,
	count(order_id) as total_orders,
	sum(total_amount) as total_spent
from orders
where customer_name is not null
group by customer_name 
order by total_spent desc;

-- Stok vs Penjualan
select
	p.product_name,
	p.stock_quantity,
	coalesce(sum(o.quantity), 0) as sold_quantity,
	round((coalesce(sum(o.quantity), 0) * 100.0 /
		(p.stock_quantity + coalesce(sum(o.quantity), 0))), 2) as sold_percentage
from products p
left join orders o on o.product_id = p.product_id and o.status = 'completed'
group by p.product_id, p.product_name, p.stock_quantity
order by sold_percentage desc;

-- join dengan multiple conditions
select
	o.order_id,
	o.order_date,
	o.customer_name,
	p.product_name,
	o.quantity,
	o.total_amount,
	o.status
from orders o
inner join products p on o.product_id = p.product_id
where o.order_date >= '2024-01-18'
and p.category = 'Electronics'
order by o.order_date desc;

-- Self-join contoh (jika ada tabel karyawan)
-- CREATE TABLE employees (
--     emp_id SERIAL PRIMARY KEY,
--     emp_name VARCHAR(100),
--     manager_id INT
-- );


-- UNION contoh
select 'High Value' as category, order_id, total_amount
from orders
where total_amount > 500
union all
select 'Low Value', order_id, total_amount
from orders
where total_amount <= 500
order by total_amount desc;

