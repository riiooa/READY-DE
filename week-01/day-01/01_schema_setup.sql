create table products (
	product_id serial primary key,
	product_name VARCHAR(100) not null,
	category varchar(50),
	price decimal (10, 2) not null,
	stock_quantity int default 0,
	create_at timestamp default current_timestamp
);
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    product_id INT,
    quantity INT NOT NULL,
    order_date DATE NOT NULL,
    customer_name VARCHAR(100),
    total_amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


alter table orders
add constraint fk_product
foreign key (product_id)
references products(product_id)
