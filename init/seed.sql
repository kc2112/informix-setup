-- Seed script for Informix (database named in .env)
-- Compatible with the official Informix Developer Edition image.

-- Drop tables if they exist (Informix syntax)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- Customers
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
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
    customer_id INTEGER NOT NULL,
    order_date  DATE DEFAULT TODAY,
    total       DECIMAL(12,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order items
CREATE TABLE order_items (
    item_id     SERIAL PRIMARY KEY,
    order_id    INTEGER NOT NULL,
    product_id  INTEGER NOT NULL,
    quantity    INTEGER NOT NULL,
    unit_price  DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Seed data
INSERT INTO customers (first_name, last_name, email) VALUES
    ('Alice', 'Johnson', 'alice@example.com');
INSERT INTO customers (first_name, last_name, email) VALUES
    ('Bob', 'Smith', 'bob@example.com');
INSERT INTO customers (first_name, last_name, email) VALUES
    ('Carol', 'Williams', 'carol@example.com');

INSERT INTO products (name, price, in_stock) VALUES
    ('Widget A', 19.99, 100);
INSERT INTO products (name, price, in_stock) VALUES
    ('Widget B', 29.50, 50);
INSERT INTO products (name, price, in_stock) VALUES
    ('Gadget C', 9.95, 200);

INSERT INTO orders (customer_id, total) VALUES (1, 49.48);
INSERT INTO orders (customer_id, total) VALUES (2, 29.50);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 19.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 3, 3, 9.83);
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (2, 2, 1, 29.50);

-- Verify
SELECT 'Seed complete' AS status FROM systables WHERE tabid = 1;
