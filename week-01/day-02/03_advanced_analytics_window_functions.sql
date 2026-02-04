-- cte dasar: monthly revenue calculation
with monthly_revenue as (
	select
		date_trunc('month', order_date) as month,
		sum(total_amount) as total_revenue
	from orders
	where status = 'completed'
	group by date_trunc('month', order_date)
)
select
	to_char(month, 'YYYY-MM') as year_month,
	total_revenue
from monthly_revenue 
order by month desc;

-- cte multiple: revenue dengan growth calculation
with monthly_revenue as (
	select
		date_trunc('month', order_date) as month,
		sum(total_amount) as total_revenue
	from orders
	where status = 'completed'
	group by date_trunc('month', order_date)
),
revenue_with_growth as (
	select
		to_char(month, 'YYYY-MM') as year_month,
		total_revenue,
		lag(total_revenue) over (order by month) as prev_month_revenue,
		total_revenue - lag(total_revenue) over (order by month) as revenue_change,
		round(
			((total_revenue - lag(total_revenue) over(order by month)) * 100.0 /
			nullif(lag(total_revenue) over (order by month), 0)), 2 
		) as growth_percentage
	from monthly_revenue
)
select
	year_month,
	total_revenue,
	prev_month_revenue,
	revenue_change,
	growth_percentage,
	case
		when growth_percentage > 0 then '📈 increase'
		when growth_percentage < 0 then '📉 decrease'
		else '➡️ no change'
	end as trend
from revenue_with_growth
order by year_month desc; 

-- rank produk berdasarkan penjualan per bulan
with monthly_product_sales as (
	select
		date_trunc('month', o.order_date) as month,
		p.product_id,
		p.product_name,
		p.category,
		sum(o.quantity) as total_quantity,
		sum(o.total_amount) as total_revenue,
		count(o.order_id) as order_count
	from orders o
	join products p on o.product_id = p.product_id
	where o.status = 'completed'
	group by
		date_trunc('month', o.order_date),
		p.product_id,
		p.product_name,
		p.category
),
ranked_products as (
	select
		to_char(month, 'YYYY-MM') as year_month,
		product_name,
		category,
		total_quantity, 
		total_revenue,
		order_count,
		row_number() over (
			partition by month
			order by total_revenue desc
		) as revenue_rank, 
		rank() over (
			partition by month
			order by total_revenue desc
		) as revenue_rank_with_ties,
		dense_rank() over (
			partition by month
			order by total_revenue desc 
		) as dense_revenue_rank,
		ntile(4) over ( 
			partition by month
			order by total_revenue desc
		) as revenue_quartile
	from monthly_product_sales
)
select
	year_month,
	product_name,
	category,
	total_quantity,
	total_revenue,
	revenue_rank,
	revenue_rank_with_ties,
	dense_revenue_rank,
	case revenue_quartile
		when 1 then 'top 25%'
		when 2 then '25-50%'
		when 3 then '50-75%'
		when 4 then 'bottom 25%'
	end as performance_category
from ranked_products
where revenue_rank <= 5
order by year_month desc, revenue_rank;

-- moving average 3 bulan
with monthly_sales as (
	select
		date_trunc('month', order_date) as month,
		sum(total_amount) as monthly_revenue
	from orders
	where status = 'completed'
	group by date_trunc('month', order_date)
)
select
	to_char(month, 'YYYY-MM') as year_month,
	monthly_revenue,
	round(avg(monthly_revenue) over (
		order by month
		rows between 2 preceding and current row
	), 2 ) as moving_avg_3month,
	round(sum(monthly_revenue) over (
		order by month
		rows between unbounded preceding and current row
	), 2) as cumulative_revenue
from monthly_sales 
order by month;

-- perbandingan penjualan produk dengan rata2 kategori
with product_category_stats as (
	select
		p.product_id,
		p.product_name,
		p.category,
		p.price,
		coalesce(sum(o.quantity), 0) as total_sold,
		coalesce(sum(o.total_amount), 0) as total_revenue,
		avg(coalesce(sum(o.total_amount), 0)) over (
			partition by p.category
		) as avg_category_revenue 
	from products p 
	left join orders o on p.product_id = o.product_id 
		and o.status = 'completed'
	group by p.product_id, p.product_name, p.category, p.price
)
select
	product_name,
	category,
	price,
	total_sold,
	total_revenue,
	round(avg_category_revenue, 2) as avg_category_revenue, 
	round(total_revenue - avg_category_revenue, 2) as diff_vs_category_avg,
	case
		when total_revenue > avg_category_revenue then 'above average'
		when total_revenue < avg_category_revenue then 'below average'
		else 'equal to average'
	end as performance_vs_category
from product_category_stats
order by category, total_revenue desc;

-- lead & lag: compare with previous/next period
with monthly_category_revenue as (
	select
		date_trunc('month', o.order_date) as month,
		p.category,
		sum(o.total_amount) as category_revenue
	from orders o
	join products p on o.product_id = p.product_id
	where o.status = 'completed'
	group by date_trunc('month', o.order_date), p.category
)
select
	to_char(month, 'YYYY-MM') as year_month,
	category,
	category_revenue,
	lag(category_revenue) over (
		partition by category
		order by month
	) as prev_month_revenue,
	lead(category_revenue) over (
		partition by category
		order by month
	) as next_month_revenue,
	round(
		(category_revenue - lag(category_revenue) over (
			partition by category
			order by month
		)) * 100.0 / nullif(lag(category_revenue) over (
			partition by category
			order by month
		), 0), 2
	) as month_over_month_growth
from monthly_category_revenue
order by category, month;

-- window frames advanced: rolling calculations
with daily_sales as (
	select
		order_date,
		sum(total_amount) as daily_revenue 
	from orders 
	where status = 'completed'
	group by order_date 
)
select
	order_date,
	daily_revenue,
	round(avg(daily_revenue) over (
		order by order_date
		rows between 29 preceding and current row
	), 2) as monthly_moving_avg, 
	round(max(daily_revenue) over(
		order by order_date
		rows between 29 preceding and current row
	), 2 ) as monthly_max,
	round(min(daily_revenue) over (
		order by order_date
		rows between 29 preceding and current row
	), 2 ) as monthly_min,
	round(daily_revenue * 100.0 / sum(daily_revenue) over (
		partition by date_trunc('month', order_date)
	), 2 ) as pct_of_monthly_total
from daily_sales
order by order_date desc;