USE shop;
USE example;

-- Первое задание --

SELECT * FROM users u WHERE EXISTS(SELECT 1 FROM orders WHERE orders.user_id = u.id);


-- Второе задание --

SELECT p.name, c.name FROM products p JOIN catalogs c ON p.catalog_id = c.id;

-- Третье задание --

DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
	id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	from_city VARCHAR(100) NOT NULL,
	to_city VARCHAR(100) NOT NULL
)

INSERT INTO flights (from_city, to_city)
VALUES
	('moscow', 'omsk'),
	('novgorod', 'kazan'),
	('irkutsk', 'moscow'),
	('omsk', 'irkutsk'),
	('moscow', 'kazan');

SELECT * FROM flights;

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
	label VARCHAR(100) NOT NULL PRIMARY KEY,
	name VARCHAR(100) UNIQUE
)

INSERT INTO cities
VALUES
	('moscow', 'Москва'),
	('novgorod', 'Новгород'),
	('irkutsk', 'Иркутск'),
	('omsk', 'Омск'),
	('kazan', 'Казань');

SELECT * FROM cities;

SELECT f.id, c1.name, c2.name
FROM flights f 
	JOIN cities c1 ON f.from_city = c1.label
	JOIN cities c2 ON f.to_city = c2.label; 




















