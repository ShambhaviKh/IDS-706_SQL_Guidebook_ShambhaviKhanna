-- Drop tables if they exist (safe re-run)
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS MenuItems;
DROP TABLE IF EXISTS Staff;

-- === Customers ===
CREATE TABLE Customers (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name TEXT NOT NULL,
    contact CHAR(10)
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
    staff_id INTEGER,
    quantity INTEGER,
    unit_price REAL,           -- this column must exist
    payment_method TEXT,
    order_time TEXT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (item_id) REFERENCES MenuItems(item_id)
);
-- === Staff ===
CREATE TABLE Staff (
    staff_id INTEGER PRIMARY KEY AUTOINCREMENT,
    staff_name TEXT NOT NULL,
    role TEXT,
    hire_date TEXT
);

INSERT INTO Customers (customer_name, contact)
VALUES 
('Mary Vega DDS', '9192345678'),
('Brandon Myers', '9293465789'),
('Margaret Wells', ' 9512364789'),
('Michael Matthews', '9342364459'),
('Connor Williams', '8991456788'),
('Matthew Miles', '7722346789'),
('Johnny Dennis', '4327182345'),
('Heidi Boyle', '2123467890'),
('Aaron Bruce', '9198765432');

INSERT INTO MenuItems (food_item, category)
VALUES
('Pasta', 'Main'),
('Salad', 'Starter'),
('Burger', 'Main'),
('Ice Cream', 'Dessert'),
('Brownie', 'Dessert'),
('Soup', 'Starter');

INSERT INTO Orders (order_id, customer_id, item_id, staff_id, quantity, unit_price, payment_method, order_time)
VALUES
(2268, 1, 1, 3, 5, 16.52, 'Cash', '2025-02-02 14:28:41'),
(3082, 2, 5, 4, 4, 17.27, 'Debit Card', '2025-06-08 10:57:47'),
(3160, 3, 1, 6, 1, 3.37, 'Credit Card', '2025-03-04 07:41:41'),
(1272, 4, 1, 2, 5, 2.20, 'Online Payment', '2025-05-15 12:43:45'),
(9447, 5, 6, 1, 1, 12.23, 'Cash', '2025-03-15 14:25:56'),
(1587, 6, 5, 1, 5, 7.39, 'Credit Card', '2025-04-12 05:49:18'),
(8018, 7, 5, 3, 5, 11.79, 'Debit Card', '2025-04-28 08:09:19'),
(5409, 8, 4, 4, 5, 4.77, 'Cash', '2025-04-28 08:32:14'),
(2857, 9, 2, 6, 4, 4.72, 'Debit Card', '2025-04-22 19:43:14');

INSERT INTO Staff (staff_name, role, hire_date)
VALUES
('Alice Johnson', 'Server', '2023-01-10'),
('David Clark', 'Cashier', '2022-11-05'),
('Emma Banks', 'Cashier', '2024-03-15'),
('James Smith', 'Manager', '2020-07-20'),
('Olivia Brown', 'Chef', '2020-09-30'),
('Nina Patel', 'Server', '2024-02-22');

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

-- Revenue generated per staff member
SELECT
  s.staff_name,
  ROUND(SUM(o.quantity * o.unit_price), 2) AS total_revenue_generated
FROM Orders o
JOIN Staff s ON o.staff_id = s.staff_id
GROUP BY s.staff_name
ORDER BY total_revenue_generated DESC;

--Longest-serving staff (based on hire_date)
SELECT
  staff_name,
  role,
  hire_date
FROM Staff
ORDER BY hire_date ASC
LIMIT 1

