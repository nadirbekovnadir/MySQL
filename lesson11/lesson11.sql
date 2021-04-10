 
-- ========================== Первая часть ========================== --
-- ================================================================== --

-- ------------------------ Первое задание ------------------------ --

USE shop;

CREATE TABLE IF NOT EXISTS logs (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE,
	table_name VARCHAR(50) NOT NULL,
	value_id BIGINT UNSIGNED NOT NULL,
	value_name VARCHAR(50) NOT NULL,
	created_at datetime NOT NULL,
	updated_at datetime NOT NULL,
	PRIMARY KEY(id)
);


DROP TRIGGER IF EXISTS users_insert_logInsert;

DELIMITER $$
CREATE TRIGGER users_insert_logInsert AFTER INSERT ON users
FOR EACH ROW
BEGIN
	INSERT INTO logs VALUES (NULL, 'users', NEW.id, NEW.name, NEW.created_at, NEW.updated_at);
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS products_insert_logInsert;

DELIMITER $$
CREATE TRIGGER products_insert_logInsert AFTER INSERT ON products
FOR EACH ROW
BEGIN
	INSERT INTO logs VALUES (NULL, 'products', NEW.id, NEW.name, NEW.created_at, NEW.updated_at);
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS catalogs_insert_logInsert;

DELIMITER $$
CREATE TRIGGER catalogs_insert_logInsert AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
	INSERT INTO logs VALUES (NULL, 'catalogs', NEW.id, NEW.name, NOW(), NOW());
END$$
DELIMITER ;

INSERT INTO catalogs (id, name) VALUES (NULL, 'TEEETS');
SELECT * FROM catalogs;
SELECT * FROM logs;


-- ------------------------ Второе задание ------------------------ --

-- Эксперимент с рекурсиями

/*WITH RECURSIVE sequence2 AS
(
	WITH RECURSIVE 
	sequence1 AS (
		SELECT 1 AS level
		UNION ALL
		SELECT level + 1 AS value FROM sequence1 WHERE sequence1.level < 10
	)
	SELECT 1 AS level
	UNION ALL
	SELECT sequence2.level + 1 FROM sequence2 CROSS JOIN sequence1 WHERE sequence2.level < 10
)
SELECT level FROM sequence2;*/

DROP PROCEDURE UsersFilling;

DELIMITER $$
CREATE PROCEDURE UsersFilling(IN cnt BIGINT)
BEGIN
	SET @counter = cnt;

	WHILE @counter > 0 DO
		INSERT INTO users VALUES (NULL, 'Лень', NOW(), NOW(), NOW(), '112332');
    	SET @counter = @counter - 1;
 	END WHILE;
END$$
DELIMITER ;

-- Отменил вставку, очень длительна
-- Вероятно, есть смысл готовить блоки заранее, чтобы оптимизировать выполнение
CALL UsersFilling(1000000);

SELECT COUNT(u.id) FROM users u;



-- ========================== Вторая часть ========================== --
-- ================================================================== --

-- ------------------------ Первое задание ------------------------ --

Выберу Hash
Они позволят хранить набор ip-адресов. Проверять их наличие, вставляя при отсутствии, инкрементируя при наличии


-- ------------------------ Второе задание ------------------------ --

Потребуется хранить пары ключ-значение
Где: ключ-имя,   значение-адрес
И
Где: ключ-адрес, значение-имя

Возможно также осуществлять хранение внутри Hash (в двух).


-- ------------------------ Третье задание ------------------------ --

{
	"type": "products", -- Название "таблицы"
	"id": "...", -- Стандартный id
	"name": "...",
	"description": "...",
	"price": "...",
	"catalog_id": "...", -- Можно расположить индекс из другой "таблицы"
	"created_at": "...",
	"updated_at": "...",
}

{
	"type": "catalogs", -- Название "таблицы"
	"name": ["...", ... , "..."],
}

-- Или же в качестве альтернативы

{
	"catalogs": 
		[
			{
				"name": "..."
				"products": [
					{
						"name": "...",
						"description": "...",
						"price": "...",
						"created_at": "...",
						"updated_at": "...",
					},
					
					...
					
					{
						"name": "...",
						"description": "...",
						"price": "...",
						"created_at": "...",
						"updated_at": "...",
					},
				]
			}	
		]
}




