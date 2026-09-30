-- Hands-On Lab: Diagnosing Slow Queries and Adding a Connection Pool

-- Step 1: Create the orders table
CREATE TABLE orders (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id INT,
  amount NUMERIC(10,2),
  status TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Generate 2,000,000 orders
INSERT INTO orders (customer_id, amount, status, created_at)
SELECT
  (random()*50000)::int,
  (random()*500)::numeric(10,2),
  (ARRAY['pending','shipped','delivered'])[ceil(random()*3)],
  now() - (random()*365)::int * interval '1 day'
FROM generate_series(1, 2000000);

ANALYZE orders;


-- Step 2: Diagnose the slow query
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, SUM(amount)
FROM orders
WHERE status = 'pending'
  AND created_at > now() - interval '30 days'
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 10;


-- Step 3: Add an index
CREATE INDEX idx_pending_recent
ON orders (created_at DESC, customer_id)
WHERE status = 'pending';


-- Rerun the query after creating the index
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, SUM(amount)
FROM orders
WHERE status = 'pending'
  AND created_at > now() - interval '30 days'
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 10;


-- Step 4: Transaction isolation test

-- Session 1:
-- BEGIN;
-- SELECT amount FROM orders WHERE id = 1;
--
-- Session 2:
-- UPDATE orders SET amount = 9999 WHERE id = 1;
-- COMMIT;
--
-- Session 1:
-- SELECT amount FROM orders WHERE id = 1;
-- COMMIT;


-- Step 5: PgBouncer configuration
-- pool_mode = transaction
-- max_client_conn = 1000
-- default_pool_size = 20
-- listen_port = 6432