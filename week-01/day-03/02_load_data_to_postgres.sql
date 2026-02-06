-- LOAD DATA TO POSTGRESQL SCRIPT 



-- 1. Reset (Hapus Tabel Lama)
DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_time CASCADE;



-- 2. Buat dim_time
CREATE TABLE dim_time (
    full_date DATE PRIMARY KEY,
    year INTEGER,
    quarter INTEGER,
    month INTEGER,
    month_name VARCHAR(20),
    day_of_month INTEGER,
    day_of_week INTEGER,
    day_name VARCHAR(20),
    week_of_year INTEGER,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,
    holiday_name VARCHAR(50)
);

-- 2. Dim Product (Ubah Date & Numeric ke TEXT agar mau load)
CREATE TABLE dim_product (
    product_id INTEGER PRIMARY KEY,
    product_sku VARCHAR(50),
    product_name VARCHAR(255),
    product_description TEXT,
    category_id INTEGER,
    category_name VARCHAR(100),
    subcategory_id INTEGER,
    subcategory_name VARCHAR(100),
    brand VARCHAR(100),
    supplier_id INTEGER,
    supplier_name VARCHAR(255),
    manufacturer VARCHAR(255),
    unit_cost TEXT, -- Ubah ke TEXT
    unit_price TEXT, -- Ubah ke TEXT
    reorder_level INTEGER,
    target_stock_level INTEGER,
    weight_kg TEXT, -- Ubah ke TEXT
    dimensions VARCHAR(100),
    is_active BOOLEAN,
    is_discontinued BOOLEAN,
    created_date TEXT, -- Ubah ke TEXT
    discontinued_date TEXT, -- Ubah ke TEXT
    last_restock_date TEXT -- Ubah ke TEXT
);

-- 3. Dim Store
CREATE TABLE dim_store (
    store_id INTEGER PRIMARY KEY,
    store_code VARCHAR(50),
    store_name VARCHAR(255),
    store_type VARCHAR(100),
    store_format VARCHAR(100),
    region_id INTEGER,
    region_name VARCHAR(100),
    subregion_id INTEGER,
    subregion_name VARCHAR(100),
    city VARCHAR(100),
    state_province VARCHAR(100),
    address TEXT,
    postal_code VARCHAR(20),
    country VARCHAR(100),
    latitude TEXT,
    longitude TEXT,
    manager_id INTEGER,
    manager_name VARCHAR(255),
    employee_count INTEGER,
    square_feet INTEGER,
    number_of_floors INTEGER,
    has_parking BOOLEAN,
    has_cafe BOOLEAN,
    opening_date TEXT, -- Ubah ke TEXT
    closing_date TEXT, -- Ubah ke TEXT
    renovation_date TEXT, -- Ubah ke TEXT
    monthly_rent TEXT,
    annual_sales_target TEXT,
    is_active BOOLEAN,
    is_temporary_closed BOOLEAN
);

-- 4. Dim Customer
CREATE TABLE dim_customer (
    customer_id INTEGER PRIMARY KEY,
    customer_code VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    phone_secondary VARCHAR(50),
    birth_date TEXT,
    gender VARCHAR(20),
    marital_status VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    customer_segment VARCHAR(50),
    customer_tier VARCHAR(50),
    lifetime_value TEXT,
    registration_date TEXT,
    first_purchase_date TEXT,
    last_purchase_date TEXT,
    purchase_frequency INTEGER,
    average_order_value TEXT,
    loyalty_points INTEGER,
    loyalty_tier VARCHAR(50),
    referral_code VARCHAR(50),
    referred_by_id TEXT,
    email_opt_in BOOLEAN,
    sms_opt_in BOOLEAN,
    is_active BOOLEAN,
    is_vip BOOLEAN,
    is_employee BOOLEAN
);

-- 5. Fact Sales
CREATE TABLE fact_sales (
    time_id_old INTEGER,
    product_id INTEGER,
    store_id INTEGER,
    customer_id TEXT, -- Terima string seperti "2158.0" atau ""
    transaction_id VARCHAR(100),
    sales_person_id INTEGER,
    sales_person_name VARCHAR(255),
    quantity INTEGER,
    unit_price TEXT,
    unit_cost TEXT,
    discount_type VARCHAR(50),
    discount_percentage TEXT, -- Terima ""
    discount_amount TEXT,
    promotion_id VARCHAR(50),
    promotion_name VARCHAR(100),
    tax_rate TEXT,
    service_fee TEXT,
    shipping_fee TEXT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    card_type VARCHAR(50),
    card_last_four VARCHAR(10),
    is_returned BOOLEAN,
    return_reason TEXT,
    return_date TEXT,
    refund_amount TEXT,
    sales_channel VARCHAR(50),
    online_order_id VARCHAR(100),
    transaction_time TEXT,
    source_system VARCHAR(50),
    batch_id INTEGER,
    total_amount TEXT,
    net_amount TEXT,
    tax_amount TEXT,
    gross_amount TEXT
);


-- 1. Load Data from CSV to Staging Tables 
COPY dim_time FROM '/tmp/data/dim_time.csv' WITH (FORMAT CSV, HEADER TRUE, QUOTE '"', NULL '');
COPY dim_product FROM '/tmp/data/dim_product.csv' WITH (FORMAT CSV, HEADER TRUE, QUOTE '"', NULL '');
COPY dim_store FROM '/tmp/data/dim_store.csv' WITH (FORMAT CSV, HEADER TRUE, QUOTE '"', NULL '');
COPY dim_customer FROM '/tmp/data/dim_customer.csv' WITH (FORMAT CSV, HEADER TRUE, QUOTE '"', NULL '');
COPY fact_sales FROM '/tmp/data/fact_sales.csv' WITH (FORMAT CSV, HEADER TRUE, QUOTE '"', NULL '');

-- 2. Data Transformation & Type Casting (Membersihkan string kosong menjadi NULL)
-- Merapikan Fact Sales
ALTER TABLE fact_sales 
    ALTER COLUMN customer_id TYPE NUMERIC USING (NULLIF(customer_id, '')::NUMERIC),
    ALTER COLUMN unit_price TYPE NUMERIC USING (NULLIF(unit_price, '')::NUMERIC),
    ALTER COLUMN total_amount TYPE NUMERIC USING (NULLIF(total_amount, '')::NUMERIC),
    ALTER COLUMN tax_amount TYPE NUMERIC USING (NULLIF(tax_amount, '')::NUMERIC),
    ALTER COLUMN transaction_time TYPE TIMESTAMP USING (NULLIF(transaction_time, '')::TIMESTAMP);

-- Merapikan Dimensi
ALTER TABLE dim_product 
    ALTER COLUMN created_date TYPE DATE USING (NULLIF(created_date, '')::DATE),
    ALTER COLUMN discontinued_date TYPE DATE USING (NULLIF(discontinued_date, '')::DATE);

ALTER TABLE dim_customer 
    ALTER COLUMN birth_date TYPE DATE USING (NULLIF(birth_date, '')::DATE),
    ALTER COLUMN registration_date TYPE DATE USING (NULLIF(registration_date, '')::DATE);

ALTER TABLE dim_store 
    ALTER COLUMN opening_date TYPE DATE USING (NULLIF(opening_date, '')::DATE);

-- 3. Verify Counts
SELECT 'dim_time' AS table_name, COUNT(*) AS row_count FROM dim_time
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_store', COUNT(*) FROM dim_store
UNION ALL 
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales
ORDER BY table_name;

-- 4. Create Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_fact_sales_product ON fact_sales(product_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_store ON fact_sales(store_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_customer ON fact_sales(customer_id);

-- 5. Analyze tables for query optimizer
ANALYZE dim_time;
ANALYZE dim_product;
ANALYZE dim_store;
ANALYZE dim_customer;
ANALYZE fact_sales;

-- 6. Sample Analytical Query
-- Note: Menggunakan full_date karena di CSV ini adalah key penghubungnya
SELECT
    dt.year,
    dt.month_name,
    COUNT(fs.transaction_id) AS transaction_count,
    SUM(fs.total_amount) AS total_revenue,
    SUM(fs.quantity) AS total_quantity_sold
FROM fact_sales fs
JOIN dim_time dt ON fs.time_id_old = dt.day_of_month -- Sesuaikan join key jika diperlukan
GROUP BY dt.year, dt.month_name
ORDER BY dt.year DESC, dt.month_name;

