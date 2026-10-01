-- ============================================
-- E-Commerce Database Schema
-- Author: Rohit Thakur
-- ============================================

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(150) UNIQUE NOT NULL,
    signup_date DATE NOT NULL,
    region      VARCHAR(50)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name       VARCHAR(150) NOT NULL,
    category   VARCHAR(80),
    price      NUMERIC(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id     SERIAL PRIMARY KEY,
    customer_id  INT REFERENCES customers(customer_id),
    order_date   DATE NOT NULL,
    status       VARCHAR(20) CHECK (status IN ('pending','completed','cancelled','refunded')),
    total_amount NUMERIC(12,2) NOT NULL
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id      INT REFERENCES orders(order_id),
    product_id    INT REFERENCES products(product_id),
    quantity      INT NOT NULL,
    unit_price    NUMERIC(10,2) NOT NULL
);

CREATE TABLE payments (
    payment_id   SERIAL PRIMARY KEY,
    order_id     INT REFERENCES orders(order_id),
    payment_date DATE NOT NULL,
    method       VARCHAR(30),
    status       VARCHAR(20) CHECK (status IN ('success','failed','refunded'))
);

-- ============================================
-- Indexes for query performance
-- ============================================
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date  ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);
