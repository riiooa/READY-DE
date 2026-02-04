-- Tabel utama
CREATE TABLE products (
    product_id serial PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2),
    dept_id INT,
    hire_date DATE,
    manager_id INT
);

-- Foreign keys
ALTER TABLE orders
ADD CONSTRAINT fk_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

ALTER TABLE employees 
ADD CONSTRAINT fk_department
FOREIGN KEY (dept_id) 
REFERENCES departments(dept_id);

ALTER TABLE employees 
ADD CONSTRAINT fk_manager 
FOREIGN KEY (manager_id) 
REFERENCES employees(emp_id);

-- Indexing untuk performa query
-- Index untuk foreign key
CREATE INDEX idx_orders_product_id ON orders(product_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_price ON products(price);

-- Composite index untuk query yang sering digunakan bersama
CREATE INDEX idx_orders_status_date ON orders(status, order_date);

-- Data sample untuk testing
INSERT INTO products (product_name, category, price, stock_quantity) VALUES
('Laptop Dell XPS 13', 'Electronics', 1299.99, 15),
('iPhone 14 Pro', 'Electronics', 999.99, 25),
('Nike Air Max', 'Fashion', 129.99, 50),
('Coffee Maker', 'Home Appliances', 79.99, 30),
('Desk Chair', 'Furniture', 199.99, 20),
('Python Crash Course', 'Books', 39.99, 100),
('Bluetooth Speaker', 'Electronics', 59.99, 40),
('Yoga Mat', 'Sports', 29.99, 60),
('Backpack', 'Fashion', 49.99, 45),
('External SSD 1TB', 'Electronics', 89.99, 35);

INSERT INTO orders (product_id, quantity, order_date, customer_name, total_amount, status) VALUES
(1, 2, '2024-01-15', 'John Doe', 2599.98, 'completed'),
(2, 1, '2024-01-16', 'Jane Smith', 999.99, 'completed'),
(3, 3, '2024-01-17', 'Bob Johnson', 389.97, 'completed'),
(5, 1, '2024-01-18', 'Alice Brown', 199.99, 'shipped'),
(7, 2, '2024-01-19', 'Charlie Wilson', 119.98, 'pending'),
(1, 1, '2024-01-20', 'David Lee', 1299.99, 'completed'),
(4, 1, '2024-01-20', 'Eva Garcia', 79.99, 'completed'),
(8, 5, '2024-01-21', 'Frank Miller', 149.95, 'shipped'),
(9, 2, '2024-01-22', 'Grace Taylor', 99.98, 'pending'),
(2, 1, '2024-01-23', 'Henry Clark', 999.99, 'completed'),
(1, 1, '2023-12-05', 'Michael Chen', 1299.99, 'completed'),
(2, 2, '2023-12-10', 'Sarah Williams', 1999.98, 'completed'),
(3, 1, '2023-12-15', 'Robert Martinez', 129.99, 'completed'),
(4, 3, '2023-12-20', 'Lisa Anderson', 239.97, 'completed'),
(5, 1, '2023-11-01', 'Kevin Thomas', 199.99, 'completed'),
(6, 2, '2023-11-05', 'Amanda Rodriguez', 79.98, 'completed'),
(7, 1, '2023-11-10', 'Brian Jackson', 59.99, 'completed'),
(8, 4, '2023-11-15', 'Jennifer White', 119.96, 'completed'),
(9, 2, '2023-10-01', 'Christopher Lee', 99.98, 'completed'),
(10, 1, '2023-10-05', 'Michelle Davis', 89.99, 'completed'),
(1, 2, '2024-02-01', 'Daniel Wilson', 2599.98, 'completed'),
(2, 1, '2024-02-03', 'Jessica Thompson', 999.99, 'completed'),
(3, 3, '2024-02-05', 'Matthew Taylor', 389.97, 'completed'),
(4, 1, '2024-02-07', 'Olivia Harris', 79.99, 'completed'),
(5, 2, '2024-02-10', 'Andrew King', 399.98, 'completed');

INSERT INTO departments (dept_name) VALUES
('Engineering'),
('Sales'),
('Marketing'),
('HR'),
('Finance');

INSERT INTO employees (emp_name, salary, dept_id, hire_date, manager_id) VALUES
('John Doe', 85000, 1, '2022-01-15', NULL),
('Jane Smith', 92000, 1, '2021-03-10', 1),
('Bob Johnson', 78000, 1, '2023-02-20', 1),
('Alice Brown', 65000, 2, '2022-06-01', NULL),
('Charlie Wilson', 72000, 2, '2021-11-15', 4),
('David Lee', 95000, 3, '2020-05-10', NULL),
('Eva Garcia', 88000, 3, '2021-08-22', 6),
('Frank Miller', 105000, 4, '2019-12-01', NULL),
('Grace Taylor', 58000, 5, '2023-01-10', NULL),
('Henry Clark', 69000, 5, '2022-09-05', 9),
('Irene Adams', 82000, 1, '2021-07-30', 1),
('Jack White', 76000, 2, '2023-03-14', 4),
('Karen Davis', 91000, 3, '2020-11-20', 6),
('Leo Martin', 87000, 4, '2022-04-18', 8),
('Mona Scott', 73000, 5, '2021-09-25', 9);

-- EXPLAIN ANALYZE untuk optimasi query
-- Query 1: Dengan kondisi WHERE
EXPLAIN ANALYZE
SELECT
    p.product_name,
    COUNT(o.order_id) AS total_orders
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
WHERE o.status = 'completed'
GROUP BY p.product_id, p.product_name;

-- Query 2: Tanpa kondisi WHERE (untuk perbandingan)
EXPLAIN ANALYZE
SELECT
    p.product_name,
    COUNT(o.order_id) AS total_orders
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name;

-- Query 3: WHERE dengan multiple conditions
EXPLAIN ANALYZE
SELECT * 
FROM orders
WHERE order_date BETWEEN '2024-01-15' AND '2024-01-20'
AND status = 'completed'
AND total_amount > 100;