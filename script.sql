-- Drop tables if they exist (safe re-run)
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS MenuItems;

-- === Customers ===
CREATE TABLE Customers (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name TEXT NOT NULL
);

-- === Menu items ===
CREATE TABLE MenuItems (
    item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    food_item TEXT NOT NULL,
    category TEXT
);

-- === Orders ===
CREATE TABLE Orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    item_id INTEGER,
    quantity INTEGER,
    unit_price REAL,           -- this column must exist
    payment_method TEXT,
    order_time TEXT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (item_id) REFERENCES MenuItems(item_id)
);

INSERT INTO Customers (customer_name)
VALUES 
('Mary Vega DDS'),
('Brandon Myers'),
('Margaret Wells'),
('Michael Matthews'),
('Connor Williams'),
('Matthew Miles');

INSERT INTO MenuItems (food_item, category)
VALUES
('Pasta', 'Main'),
('Brownie', 'Dessert'),
('Soup', 'Starter');

INSERT INTO Orders (order_id, customer_id, item_id, quantity, unit_price, payment_method, order_time)
VALUES
(2268, 1, 1, 5, 16.52, 'Cash', '2025-02-02 14:28:41'),
(3082, 2, 2, 4, 17.27, 'Debit Card', '2025-06-08 10:57:47'),
(3160, 3, 1, 1, 3.37, 'Credit Card', '2025-03-04 07:41:41'),
(1272, 4, 1, 5, 2.20, 'Online Payment', '2025-05-15 12:43:45'),
(9447, 5, 3, 1, 12.23, 'Cash', '2025-03-15 14:25:56'),
(1587, 6, 2, 5, 7.39, 'Credit Card', '2025-04-12 05:49:18');

-- Update an order price
UPDATE Orders
SET unit_price = 2.20
WHERE order_id = 1272;

-- Confirm update
SELECT order_id, unit_price FROM Orders WHERE order_id = 1272;

-- Total orders and total revenue
SELECT
  COUNT(*) AS total_orders,
  ROUND(SUM(quantity * unit_price), 2) AS total_revenue
FROM Orders;

-- Average quantity and max order value
SELECT
  ROUND(AVG(quantity), 2) AS avg_quantity,
  MAX(quantity * unit_price) AS max_order_value
FROM Orders;

-- Total spent per customer
SELECT
  c.customer_name,
  ROUND(SUM(o.quantity * o.unit_price), 2) AS total_spent
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_spent DESC;

-- Most popular menu item
SELECT
  m.food_item,
  SUM(o.quantity) AS total_qty
FROM Orders o
JOIN MenuItems m ON o.item_id = m.item_id
GROUP BY m.food_item
ORDER BY total_qty DESC
LIMIT 1;

-- Orders count by payment method
SELECT
  payment_method,
  COUNT(*) AS orders_count
FROM Orders
GROUP BY payment_method
HAVING COUNT(*) >= 1
ORDER BY orders_count DESC;

-- Detailed order info with computed totals and classification
SELECT
  o.order_id,
  c.customer_name,
  m.food_item,
  o.quantity,
  o.unit_price,
  ROUND(o.quantity * o.unit_price, 2) AS order_total,
  CASE
    WHEN o.quantity >= 5 THEN 'Bulk Order'
    WHEN o.quantity BETWEEN 2 AND 4 THEN 'Medium'
    ELSE 'Small'
  END AS order_type
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN MenuItems m ON o.item_id = m.item_id
ORDER BY o.order_time;

-- Ranking customers by total spend
WITH customer_spend AS (
  SELECT
    c.customer_name,
    SUM(o.quantity * o.unit_price) AS total_spent
  FROM Orders o
  JOIN Customers c ON o.customer_id = c.customer_id
  GROUP BY c.customer_name
)
SELECT
  customer_name,
  ROUND(total_spent, 2) AS total_spent,
  RANK() OVER (ORDER BY total_spent DESC) AS spend_rank,
  ROW_NUMBER() OVER (ORDER BY total_spent DESC) AS rn
FROM customer_spend
ORDER BY spend_rank;

-- Previous order total per customer
WITH order_totals AS (
  SELECT
    o.order_id,
    c.customer_name,
    o.order_time,
    o.quantity * o.unit_price AS order_total
  FROM Orders o
  JOIN Customers c ON c.customer_id = o.customer_id
)
SELECT
  order_id,
  customer_name,
  order_time,
  order_total,
  LAG(order_total) OVER (PARTITION BY customer_name ORDER BY order_time) AS previous_order_total
FROM order_totals
ORDER BY customer_name, order_time;

-- Normalize payment method and extract order month
SELECT
  REPLACE(LOWER(payment_method), '_', ' ') AS payment_method_norm,
  substr(order_time, 1, 7) AS order_month,
  quantity * unit_price AS order_total
FROM Orders;

-- Spending category per customer
WITH spending AS (
  SELECT
    c.customer_id,
    COALESCE(c.customer_name, 'UNKNOWN') AS customer_name,
    SUM(o.quantity * o.unit_price) AS total_spent
  FROM Customers c
  LEFT JOIN Orders o ON o.customer_id = c.customer_id
  GROUP BY c.customer_id, c.customer_name
)
SELECT
  'High' AS spend_category,
  customer_name,
  ROUND(total_spent, 2) AS total_spent
FROM spending
WHERE total_spent > 50

UNION

SELECT
  'Low',
  customer_name,
  ROUND(COALESCE(total_spent, 0), 2)
FROM spending
WHERE COALESCE(total_spent, 0) <= 50
ORDER BY spend_category DESC, total_spent DESC;