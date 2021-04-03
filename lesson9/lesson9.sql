-- ========================== Первая часть ========================== --
-- ================================================================== --

-- ------------------------ Первое задание ------------------------ --

SELECT * FROM shop.users u;
SELECT * FROM sample.users u;
TRUNCATE TABLE sample.users;

SET @user_id = 1;

-- Видимо воспользоваться данной заготовкой в качестве подзапроса не выйдет...
PREPARE ourUser FROM 'SELECT id, name FROM shop.users u2 WHERE u2.id = ?;';

START TRANSACTION;
-- EXECUTE ourUser USING @user_id;
INSERT INTO sample.users
	-- (EXECUTE ourUser USING @user_id);
	(SELECT id, name FROM shop.users u WHERE id = @user_id);
		
DELETE FROM shop.users u WHERE u.id = @user_id;
-- ROLLBACK;
COMMIT;


-- ------------------------ Второе задание ------------------------ --

SElECT * FROM shop.products LIMIT 100;
SElECT * FROM shop.catalogs LIMIT 100;

CREATE VIEW prod_view (prod_name, cat_name)
	AS SELECT p.name, c.name FROM shop.products p LEFT JOIN shop.catalogs c ON p.catalog_id = c.id;
	
SELECT * FROM prod_view;


-- ------------------------ Третье задание ------------------------ --


USE sample;
DROP TABLE IF EXISTS l8_table; 
CREATE TABLE l8_table (
	id int unsigned not null primary key auto_increment,
	created_at datetime
);

INSERT INTO l8_table (created_at)
VALUES
	('2018-08-01'),
	('2018-08-04'),
	('2018-08-16'),
	('2018-08-17')
;

SELECT * FROM l8_table;

SET @currMonth = '2018-08-01';
SET @currDate = LAST_DAY('2018-07-01');

-- Эксперимент
DROP TABLE IF EXISTS counter;
CREATE TABLE IF NOT EXISTS counter (
	id TINYINT unsigned NOT NULL PRIMARY KEY auto_increment,
	created_at datetime NOT NULL
);


-- Вопрос о генерировании набора строк остается открытым...
-- Есть ли таблица с макс количеством строк, которая будет использовваться как вспомогательная?
-- Можно конечно легко сделать это при помощи cross join
-- Может можно воспользоваться функцией BENCHMARK(), чтобы сгенерировать нужное количество строк, которые будут заполнены
INSERT INTO counter (created_at)
	(SELECT @currDate := ADDDATE(@currDate, INTERVAL 1 DAY) FROM sys.metrics m WHERE DATEDIFF(LAST_DAY(@currMonth), @currDate) > 0);

SELECT * FROM counter;

-- Оказалось нельзя ссылаться из view на temporary table или вставлять переменные, что весьма досадно	
CREATE VIEW data_view (id, created_at, isContains)
AS
SELECT c.id, c.created_at, IF(ISNULL(l.created_at) = 1, 0, 1) FROM counter c LEFT JOIN l8_table l ON c.created_at = l.created_at;
;

SELECT * FROM data_view;


-- ------------------------ Четвертое задание ------------------------ --

-- Можно пользоваться view вместо подзапросов
DELETE FROM counter c1 WHERE c1.id NOT IN((SELECT id FROM (SELECT id FROM counter c2 ORDER BY c2.created_at DESC LIMIT 5) c22));


-- ================================================================== --
-- ================================================================== --



-- ========================== Вторая часть ========================== --
-- ================================================================== --

-- ------------------------ Первое задание ------------------------ --

DROP USER shop_read;
CREATE USER shop_read IDENTIFIED WITH sha256_password BY '123';
GRANT USAGE, SELECT ON shop.* TO shop_read;

SHOW GRANTS FOR shop_read;

DROP USER shop;
CREATE USER shop IDENTIFIED WITH sha256_password BY '123';
GRANT ALL ON shop.* TO shop;

SHOW GRANTS FOR shop;


-- ------------------------ Второе задание ------------------------ --

USE shop;

ALTER TABLE users
ADD COLUMN password int;

SELECT * FROM users;

UPDATE users
SET password = RAND() * 25365574; 


CREATE ALGORITHM = TEMPTABLE VIEW username (id, name) 
AS SELECT u.id, u.name FROM users u;

DROP USER user_read;
CREATE USER user_read IDENTIFIED WITH sha256_password BY '123';
GRANT USAGE, SELECT ON shop.username TO user_read;

SHOW GRANTS FOR user_read;


-- ================================================================== --
-- ================================================================== --



-- ========================== Третья часть ========================== --
-- ================================================================== --

-- ------------------------ Первое задание ------------------------ --

SET @@global.log_bin_trust_function_creators = 1;

DROP FUNCTION IF EXISTS hello;

-- dbeaver не может его сменить...
DELIMITER $$
CREATE FUNCTION hello()
RETURNS varchar(13) NOT DETERMINISTIC
BEGIN
	DECLARE currTime TIME DEFAULT TIME_FORMAT(NOW(),'%H:%i:%s');
	SET @answer = 'Добрый вечер';

	IF (currTime < '06:00:00') THEN
		SET @answer = 'Доброй ночи';
	ELSEIF (currTime < '12:00:00') THEN
		SET @answer = 'Доброе утро';
	ELSEIF (currTime < '18:00:00') THEN
		SET @answer = 'Добрый день';
	END IF;

  	RETURN @answer;
END$$
DELIMITER ;

SELECT hello();


-- ------------------------ Второе задание ------------------------ --

SELECT * FROM products;

DROP TRIGGER IF EXISTS products_insertControl;

DELIMITER $$
CREATE TRIGGER products_insertControl BEFORE INSERT ON products
FOR EACH ROW
BEGIN
	
	IF (ISNULL(NEW.name) AND ISNULL(NEW.description)) THEN
		SET NEW.name = 'Надо бы заполнить!';
		SET NEW.description = 'Надо бы заполнить!';
	END IF;
	
END$$
DELIMITER ;

INSERT INTO products (id, name, description, price, catalog_id) VALUES (8, NULL, NULL, 864553, 1);
INSERT INTO products (id, name, description, price, catalog_id) VALUES (9, 'ssaass', NULL, 864553, 1);

DELETE FROM products WHERE id = 8 OR id = 9;

SELECT * FROM products;

DROP TRIGGER IF EXISTS products_updateControl;

DELIMITER $$
CREATE TRIGGER products_updateControl AFTER UPDATE ON products
FOR EACH ROW
BEGIN
	
	IF (ISNULL(NEW.name) AND ISNULL(NEW.description)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Update canceled';
	END IF;
	
END$$

SELECT * FROM products;

UPDATE products
SET products.name = NULL WHERE id = 8;

UPDATE products
SET products.description = NULL WHERE id = 8;

DELIMITER ;


-- ------------------------ Третье задание ------------------------ --

-- Рекурсия - зло!
DROP FUNCTION IF EXISTS FIBONACCI;

DELIMITER $$
CREATE FUNCTION FIBONACCI(cnt INT)
RETURNS INT NOT DETERMINISTIC
BEGIN
	DECLARE prev INT DEFAULT 0;
	DECLARE curr INT DEFAULT 1;
	
	IF (cnt = 0) THEN
		RETURN 0;
	END IF;

	SET cnt = cnt - 1;
	WHILE (cnt > 0) DO
		SET curr = prev + curr;
		SET prev = curr - prev;
		SET cnt = cnt - 1;
  	END WHILE;
	
  	RETURN curr;
END$$
DELIMITER ;

SELECT FIBONACCI(10);


















