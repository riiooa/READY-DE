-- recursive cte: organizational hierarchy
with recursive org_hierarchy as (
	-- anchor member: top-level employees (no manager)
	select
		emp_id,
		emp_name,
		manager_id,
		salary,
		1 as level,
		emp_name::text as hierarchy_path
	from employees
	where manager_id is null

	union all
	
	-- recursive member: subordinates
	select 
		e.emp_id,
		e.emp_name,
		e.manager_id,
		e.salary,
		oh.level + 1,
		oh.hierarchy_path || ' -> ' || e.emp_name
	from employees e 
	inner join org_hierarchy oh on e.manager_id = oh.emp_id
)
select
	emp_name,
	level,
	hierarchy_path,
	salary,
	case
		when level = 1 then 'director'
		when level = 2 then 'manager'
		when level = 3 then 'senior'
		else 'junior'
	end as position_level
from org_hierarchy
order by level, emp_name;

-- customer lifetime value analysis
with customer_metrics as (
	select
		customer_name,
		count(distinct order_id) as order_count,
		min(order_date) as first_order_date,
		max(order_date) as last_order_date,
		sum(total_amount) as total_spent,
		avg(total_amount) as avg_order_value
	from orders
	where customer_name is not null
		and status = 'completed'
	group by customer_name
	having count(distinct order_id) >= 1 
),
customer_segments as (
	select
		customer_name,
		order_count,
		first_order_date,
		last_order_date,
		total_spent,
		avg_order_value,
		case
			when total_spent >= 2000 then 'platinum'
			when total_spent >= 1000 then 'gold'
			when total_spent >= 500 then 'silver'
			else 'bronze'
		end as customer_tier,
		(last_order_date - first_order_date) as customer_lifetime_days,
		round(total_spent / nullif((last_order_date - first_order_date + 1), 0), 2) as daily_spent_rate
	from customer_metrics 
)
select
	customer_name,
	customer_tier,
	order_count,
	total_spent,
	avg_order_value,
	customer_lifetime_days,
	daily_spent_rate,
	rank() over (order by total_spent desc) as spent_rank,
	dense_rank() over (order by order_count desc) as frequency_rank
from customer_segments 
order by total_spent desc;