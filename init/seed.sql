-- Seed script for the database named in .env (INFORMIX_DATABASE)
-- Executed automatically by post_init.sh after the database is created.

-- Drop tables if they already exist (safe re-run)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- Customers
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    email       VARCHAR(100) UNIQUE NOT NULL,
    created_at  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND
);

-- Products
CREATE TABLE products (
    product_id  SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    price       DECIMAL(10,2) NOT NULL,
    in_stock    INTEGER DEFAULT 0
);

-- Orders
CREATE TABLE orders (
    order_id    SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date  DATE DEFAULT TODAY,
    total       DECIMAL(12,2) DEFAULT 0
);

-- Order items
CREATE TABLE order_items (
    item_id     SERIAL PRIMARY KEY,
    order_id    INTEGER NOT NULL REFERENCES orders(order_id),
    product_id  INTEGER NOT NULL REFERENCES products(product_id),
    quantity    INTEGER NOT NULL,
    unit_price  DECIMAL(10,2) NOT NULL
);

-- Seed data
INSERT INTO customers (first_name, last_name, email) VALUES
    ('Alice', 'Johnson', 'alice@example.com'),
    ('Bob',   'Smith',   'bob@example.com'),
    ('Carol', 'Williams','carol@example.com');

INSERT INTO products (name, price, in_stock) VALUES
    ('Widget A', 19.99, 100),
    ('Widget B', 29.50, 50),
    ('Gadget C', 9.95,  200);

INSERT INTO orders (customer_id, total) VALUES
    (1, 49.48),
    (2, 29.50);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 19.99),
    (1, 3, 3, 9.83),
    (2, 2, 1, 29.50);

-- Verify seed
SELECT 'Seed complete' AS status FROM systables WHERE tabid = 1;
