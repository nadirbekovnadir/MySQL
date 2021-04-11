 
-- ========================== Первая часть ========================== --
-- ================================================================== --

Увидел, что забыл самое главное - сменить тип таблицы на Archive
Произвел корректировку в данном коммите
(Плюс мелкие изменения)

-- ------------------------ Первое задание ------------------------ --

USE shop;

DROP TABLE IF EXISTS logs;
CREATE TABLE IF NOT EXISTS logs (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	table_name VARCHAR(50) NOT NULL,
	value_id BIGINT UNSIGNED NOT NULL,
	value_name VARCHAR(50) NOT NULL,
	created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = Archive;

DROP TRIGGER IF EXISTS users_insert_logInsert;

DELIMITER $$
CREATE TRIGGER users_insert_logInsert AFTER INSERT ON users
FOR EACH ROW
BEGIN
	INSERT INTO logs VALUES (NULL, 'users', NEW.id, NEW.name, DEFAULT);
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS products_insert_logInsert;

DELIMITER $$
CREATE TRIGGER products_insert_logInsert AFTER INSERT ON products
FOR EACH ROW
BEGIN
	INSERT INTO logs VALUES (NULL, 'products', NEW.id, NEW.name, DEFAULT);
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS catalogs_insert_logInsert;

DELIMITER $$
CREATE TRIGGER catalogs_insert_logInsert AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
	INSERT INTO logs VALUES (NULL, 'catalogs', NEW.id, NEW.name, DEFAULT);
END$$
DELIMITER ;

INSERT INTO catalogs (id, name) VALUES (NULL, 'TEEETS');
SELECT * FROM catalogs;
SELECT * FROM logs;


-- ------------------------ Второе задание ------------------------ --

-- Эксперимент с рекурсиями
-- Вероятно подход имеет право на жизнь, однако, проверка с небольшими значениями level выполнялась крайне долго
-- Вариант с CROSS JOIN пытался использовать в предыдущих уроках. Данный подход неудобен для автоматизации.

-- Увидел в уроке, что все же требовался запрос и, не досмотрев дальнейшего разбора решил доделать рекурсию
-- Немного подумал и понял, где была ошибка. Довел рекурсию до логического конца

-- Можно использовать для задания последовательно увеличивающегося счетчика
SET @cnt = 0;

-- Для оптимизации стоило бы создать временную таблицу (или постоянную, которая будет удалена)
-- В дальнейшем используя ее в качестве некоторого универсально счетчика (с максимумом равным 1000000 строкам)
INSERT INTO users
	WITH RECURSIVE sequence2 AS
	(
		WITH RECURSIVE 
		sequence1 AS (
			SELECT 1 AS level
			UNION ALL
			SELECT level + 1 AS value FROM sequence1 WHERE sequence1.level < 2
		)
		SELECT 1 AS level
		UNION ALL
		SELECT sequence2.level + 1 FROM sequence2 CROSS JOIN sequence1 WHERE sequence2.level < 20 LIMIT 1000000
	)
	SELECT NULL, 'Рекурсия', NOW(), NOW(), NOW(), '112332' FROM sequence2;


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
-- CALL UsersFilling(1000000);

SELECT u.id, u.name FROM users u order by id DESC LIMIT 100;



-- ========================== Вторая часть ========================== --
-- ================================================================== --

Увидел на уроке, что требовалось привести команды в качастве решения, однако, не буду исправлять задним числом

-- ------------------------ Первое задание ------------------------ --

Выберу Hash
Они позволят хранить набор ip-адресов. Проверять их наличие, вставляя при отсутствии, инкрементируя при наличии


-- ------------------------ Второе задание ------------------------ --

Потребуется хранить пары ключ-значение
Где: ключ-имя,   значение-адрес
И
Где: ключ-адрес, значение-имя

Возможно также осуществлять хранение внутри Hash (в двух) по схеме, приведенной выше.


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




