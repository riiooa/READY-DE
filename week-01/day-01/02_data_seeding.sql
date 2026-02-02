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
(2, 1, '2024-01-23', 'Henry Clark', 999.99, 'completed');
