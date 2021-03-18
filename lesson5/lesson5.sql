USE Lesson5;

SELECT * FROM users;
SELECT * FROM storehouses_products;

-- Первая часть --
-- ============ --

-- Первое задание --
UPDATE users
SET
	created_at = NULL,
	updated_at = NULL;
	
UPDATE users
SET
	created_at = NOW(),
	updated_at = NOW();


-- Второе задание
ALTER TABLE users
ADD cr_at VARCHAR(50),
ADD up_at VARCHAR(50);

UPDATE users
SET
	cr_at = created_at,
	up_at = updated_at;

UPDATE users
SET
	created_at = NULL,
	updated_at = NULL;

UPDATE users
SET
	created_at = cr_at,
	updated_at = up_at;
	
ALTER TABLE users
DROP COLUMN cr_at,
DROP COLUMN	up_at;


-- Третье задание
SELECT * FROM storehouses_products ORDER BY IF(value != 0, value, ~0);


-- Четвертое задание
SELECT * FROM users WHERE MONTHNAME(birthday_at) IN('May', 'August');


-- Пятое задание
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5, 1, 2);

-- ============ --


-- Вторая часть --
-- ============ --

-- Первое задание
SELECT AVG(YEAR(NOW()) - YEAR(birthday_at)) FROM users;


-- Второе задание
SELECT COUNT(*), DAYNAME(DATE_ADD(birthday_at, INTERVAL YEAR(NOW()) - YEAR(birthday_at) YEAR)) AS dn FROM users GROUP BY dn ORDER BY FIELD(dn, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');


-- Третье задание
SELECT EXP(SUM(LN(value))) FROM storehouses_products WHERE value != 0;

-- ============ --








