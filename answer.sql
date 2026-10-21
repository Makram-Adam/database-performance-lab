
-- 1. Drop the IdxPhone index from customers
DROP INDEX IdxPhone ON customers;

-- 2. Create the bob user on localhost
CREATE USER 'bob'@'localhost' IDENTIFIED BY '1157';

-- 3. Grant INSERT permission on salesDB
GRANT INSERT ON salesDB.* TO 'bob'@'localhost';

-- 4. Change bob's password
ALTER USER 'bob'@'localhost' IDENTIFIED BY '1157';
