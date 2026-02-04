-- problem 1: second highest salary
-- method 1: using limit and offset
select
	coalesce(
		(select distinct salary
		from employees
		order by salary desc
		limit 1 offset 1),
		null
	) as second_highest_salary;

-- method 2: using max with subquery
select max(salary) as second_highest_salary
from employees 
where salary < (select max(salary) from employees);

-- method 3: using dense_rank
with ranked_salaries as (
	select
		salary,
		dense_rank() over (order by salary desc) as salary_rank
	from employees 
)
select
	coalesce(
		(select salary
		from ranked_salaries
		where salary_rank = 2
		limit 1),
		null
	) as second_highest_salary;

-- problem 2: department top three salaries
with department_ranking as (
	select
		e.emp_name,
		e.salary,
		d.dept_name,
		dense_rank() over (
			partition by d.dept_id
			order by e.salary desc
		) as salary_rank
	from employees e 
	join departments d on e.dept_id = d.dept_id 
)
select
	dept_name as department,
	emp_name as employee,
	salary as salary,
	salary_rank as rank
from department_ranking 
where salary_rank <= 3
order by dept_name, salary_rank, emp_name;

-- problem 3: rank scores
create table scores (
	id serial primary key,
	score decimal(5, 2)
);

insert into scores (score) values
(3.50), (3.65), (4.00), (3.85), (4.00), (3.65);

select
	score,
	dense_rank() over (order by score desc) as rank
from scores
order by score desc;

-- problem 4: consecutive numbers
create table logs (
	id serial primary key,
	num int
);

insert into logs (num) values
(1), (1), (1), (2), (1), (2), (2), (2), (2), (3), (3);

with consecutive_group as (
	select
		num,
		id,
		row_number() over (order by id) -
		row_number() over (partition by num order by id ) as grp
	from logs		
),
consecutive_counts as (
	select
		num,
		count(*) as consecutive_count
	from consecutive_group
	group by num, grp 
	having count(*) >= 3
)
select distinct num as consecutivenums
from consecutive_counts;

-- problem 5: employees earning more then their managers
select
	e.emp_name as employee,
	e.salary as employeesalary,
	m.emp_name as manager,
	m.salary as managersalary
from employees e
left join employees m on e.manager_id = m.emp_id 
where e.salary > m.salary;

-- problem 6: department highest salary
with department_salary_max as (
	select
		d.dept_id,
		d.dept_name,
		max(e.salary) as max_salary
	from departments d 
	join employees e on d.dept_id = e.dept_id 
	group by d.dept_id, d.dept_name 
)
select
	d.dept_name as department,
	e.emp_name as employee,
	e.salary as salary
from employees e 
join departments d on e.dept_id = d.dept_id 
join department_salary_max dms on d.dept_id = dms.dept_id 
where e.salary = dms.max_salary 
order by d.dept_name;

-- problem 7 exchange seats
create table seat (
	id serial primary key,
	student varchar(50)
);

insert into seat (student) values
('abbot'), ('doris'), ('emerson'), ('green'), ('jeames');

select
	id,
	case
		when id % 2 = 1 and id = (select max(id) from seat) then student
		when id % 2 = 1 then lead(student) over (order by id)
		when id % 2 = 0 then lag(student) over (order by id)
	end as student
from seat
order by id;

-- problem 8: trips and users (simplified)
create table trips (
	id serial primary key,
	client_id int,
	driver_id int,
	city_id int,
	status varchar(20),
	request_at date
);

create table users (
	users_id int primary key,
	banned varchar(3),
	role varchar(10)
);

insert into trips (client_id, driver_id, city_id, status, request_at) values
(1, 10, 1, 'completed', '2023-10-01'),
(2, 11, 1, 'cancelled_by_driver', '2023-10-01'),
(3, 12, 2, 'completed', '2023-10-02'),
(4, 13, 2, 'cancelled_by_client', '2023-10-02'),
(1, 10, 1, 'completed', '2023-10-03');

insert into users (users_id, banned, role) values
(1, 'no', 'client'),
(2, 'yes', 'client'),
(3, 'no', 'client'),
(4, 'no', 'client'),
(10, 'no', 'driver'),
(11, 'no', 'driver'),
(12, 'yes', 'driver'),
(13, 'no', 'driver');

-- daily cancellation rate of non-banned users
with valid_trips as (
	select
		t.request_at,
		t.status,
		case
			when t.status like 'cancelled%' then 1
			else 0
		end as is_cancelled
	from trips t 
	join users uc on t.client_id = uc.users_id and uc.banned = 'no'
	join users ud on t.driver_id = ud.users_id and ud.banned = 'no'
	where t.request_at between '2023-10-01' and '2023-10-03'
)
select
	request_at as day,
	round(
		sum(is_cancelled) * 100.0 / count(*),
		2
	) as "cancellation rate"
from valid_trips 
group by request_at 
order by request_at;

-- problem 9: cumulative sum
select
	emp_name,
	dept_name,
	salary,
	sum(salary) over (
		partition by d.dept_id
		order by e.emp_id
	) as cumulative_salary,
	round(
		salary * 100.0 / sum(salary) over (partition by d.dept_id),
		2
	) as pct_of_dept_total
from employees e
join departments d on e.dept_id = d.dept_id
order by d.dept_name, e.emp_id;

-- problem 10: gap analysis (find missing numbers in sequence)
with order_gaps as (
	select
		order_id,
		lead(order_id) over (order by order_id) as next_order_id
	from orders
)
select
	order_id + 1 as gap_start,
	next_order_id - 1 as gap_end 
from order_gaps 
where next_order_id - order_id > 1;