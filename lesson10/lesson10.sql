
-- ------------------------ Первое задание ------------------------ --

-- Так как данный процесс скорее творческий, а сама методика довольно проста и понятна, буду добавлять индексы в бд с курсовым проектом. 
-- Также забыл сказать, что сменил сервис с aliexpress, на существующий магазин дверей. Бд возможно будет использоваться на практике, поэтому решил, 
-- что это отличная возможность потренироваться (с реальной обратной связью).

-- Не могу не отметить. В бд vk можно отмечать в качестве индекса большинство полей и их сочетаний. При этом в движке InnoDB по-умолчанию используются индексы типа BTREE,
-- что может быть не совсем рациональным при сравнении текстовых полей (поиск по сообщению и т.д.).

-- ------------------------ Второе задание ------------------------ --

USE vk;

SELECT DISTINCT
	c.name,
	COUNT(p.user_id)  OVER()/(SELECT COUNT(*) FROM vk.communities) 	AS aver,
	MIN(p.birthday)   OVER uInG 									AS Youngest,
	MAX(p.birthday)   OVER uInG 									AS Oldest,
	COUNT(p.user_id)  OVER uInG 									AS users,
	COUNT(p.user_id)  OVER()										AS vse,
	(COUNT(p.user_id) OVER uInG)/(COUNT(c.id) OVER())*100			AS '%'
FROM vk.communities c
LEFT JOIN vk.communities_users cu ON cu.community_id = c.id
LEFT JOIN vk.profiles p ON p.user_id = cu.user_id
WINDOW uInG AS (PARTITION BY c.id)
;


-- ------------------------ Третье задание ------------------------ --

EXPLAIN ANALYZE
SELECT u.id,
  COUNT(DISTINCT ms.id) + 
  COUNT(DISTINCT l.id) +
  COUNT(DISTINCT me.id) AS activity 
FROM users u
LEFT JOIN messages ms ON u.id = ms.from_user_id
LEFT JOIN likes l ON u.id = l.user_id
LEFT JOIN media me ON u.id = me.user_id
GROUP BY u.id
ORDER BY activity
LIMIT 10;

-- -> Limit: 10 row(s)  (actual time=0.606..0.607 rows=10 loops=1)
--     -> Sort: ((count(distinct ms.id) + count(distinct l.id)) + count(distinct me.id)), limit input to 10 row(s) per chunk  (actual time=0.605..0.606 rows=10 loops=1)
--         -> Stream results  (actual time=0.051..0.570 rows=100 loops=1)
--             -> Group aggregate: count(distinct me.id), count(distinct l.id), count(distinct ms.id)  (actual time=0.049..0.542 rows=100 loops=1)
--                 -> Nested loop left join  (cost=136.93 rows=148) (actual time=0.038..0.477 rows=126 loops=1)
--                     -> Nested loop left join  (cost=85.08 rows=148) (actual time=0.035..0.305 rows=126 loops=1)
--                         -> Nested loop left join  (cost=45.25 rows=100) (actual time=0.032..0.181 rows=100 loops=1)
--                             -> Index scan on u using PRIMARY  (cost=10.25 rows=100) (actual time=0.023..0.035 rows=100 loops=1)
--                             -> Index lookup on ms using messages_fk_from_user_id (from_user_id=u.id)  (cost=0.25 rows=1) (actual time=0.001..0.001 rows=1 loops=100)
--                         -> Index lookup on l using likes_fk_user_id (user_id=u.id)  (cost=0.25 rows=1) (actual time=0.001..0.001 rows=1 loops=100)
--                     -> Index lookup on me using media_fk_user_id (user_id=u.id)  (cost=0.25 rows=1) (actual time=0.001..0.001 rows=1 loops=126)


-- Участок ниже отображает процесс объединения таблиц между собой. В самой внутренней части выполняется самый первый join, а в самой внешней - последний join.
-- Как мы видим процесс весьма затратный по ресурсам
-- Выполнив денормализацию, то есть, создав промежуточную таблицу (избыточную и не соответствующую нормальным формам) 
-- или же представление, можно попробовать ускорить данный процесс

-- 					-> Nested loop left join  (cost=136.93 rows=148) (actual time=0.038..0.477 rows=126 loops=1)
--                     -> Nested loop left join  (cost=85.08 rows=148) (actual time=0.035..0.305 rows=126 loops=1)
--                         -> Nested loop left join  (cost=45.25 rows=100) (actual time=0.032..0.181 rows=100 loops=1)
--                             -> Index scan on u using PRIMARY  (cost=10.25 rows=100) (actual time=0.023..0.035 rows=100 loops=1)
--                             -> Index lookup on ms using messages_fk_from_user_id (from_user_id=u.id)  (cost=0.25 rows=1) (actual time=0.001..0.001 rows=1 loops=100)
--                         -> Index lookup on l using likes_fk_user_id (user_id=u.id)  (cost=0.25 rows=1) (actual time=0.001..0.001 rows=1 loops=100)
--                     -> Index lookup on me using media_fk_user_id (user_id=u.id)  (cost=0.25 rows=1) (actual time=0.001..0.001 rows=1 loops=126)

CREATE OR REPLACE VIEW testView AS
SELECT u.id as uid, ms.id as msid, l.id as lid, me.id as meid FROM users u
LEFT JOIN messages ms ON u.id = ms.from_user_id
LEFT JOIN likes l ON u.id = l.user_id
LEFT JOIN media me ON u.id = me.user_id;

EXPLAIN ANALYZE
SELECT uid,
  COUNT(DISTINCT msid) + 
  COUNT(DISTINCT lid) +
  COUNT(DISTINCT meid) AS activity 
FROM testView
GROUP BY uid
ORDER BY activity
LIMIT 10;

-- -> Limit: 10 row(s)  (actual time=1.616..1.619 rows=10 loops=1)
--     -> Sort: ((count(distinct ms.id) + count(distinct l.id)) + count(distinct me.id)), limit input to 10 row(s) per chunk  (actual time=1.615..1.616 rows=10 loops=1)
--         -> Stream results  (actual time=0.101..1.525 rows=100 loops=1)
--             -> Group aggregate: count(distinct me.id), count(distinct l.id), count(distinct ms.id)  (actual time=0.098..1.447 rows=100 loops=1)
--                 -> Nested loop left join  (cost=136.93 rows=148) (actual time=0.070..1.272 rows=126 loops=1)
--                     -> Nested loop left join  (cost=85.08 rows=148) (actual time=0.063..0.829 rows=126 loops=1)
--                         -> Nested loop left join  (cost=45.25 rows=100) (actual time=0.055..0.482 rows=100 loops=1)
--                             -> Index scan on u using PRIMARY  (cost=10.25 rows=100) (actual time=0.038..0.069 rows=100 loops=1)
--                             -> Index lookup on ms using messages_fk_from_user_id (from_user_id=u.id)  (cost=0.25 rows=1) (actual time=0.003..0.004 rows=1 loops=100)
--                         -> Index lookup on l using likes_fk_user_id (user_id=u.id)  (cost=0.25 rows=1) (actual time=0.002..0.003 rows=1 loops=100)
--                     -> Index lookup on me using media_fk_user_id (user_id=u.id)  (cost=0.25 rows=1) (actual time=0.002..0.003 rows=1 loops=126)

-- Скорость выполнения менялась от запуска к запуска, следовательно по cost можно примерно судить о скорости выполнения.
-- Логично, что произошло мало изменений, так как view - вложенный запрос (при merge).
-- Применим модифицированный view и сравним быстродействие запроса.


CREATE OR REPLACE ALGORITHM=TEMPTABLE VIEW testView_temp AS
SELECT u.id as uid, ms.id as msid, l.id as lid, me.id as meid FROM users u
LEFT JOIN messages ms ON u.id = ms.from_user_id
LEFT JOIN likes l ON u.id = l.user_id
LEFT JOIN media me ON u.id = me.user_id;


EXPLAIN ANALYZE
SELECT uid,
  COUNT(DISTINCT msid) + 
  COUNT(DISTINCT lid) +
  COUNT(DISTINCT meid) AS activity 
FROM testView_temp
GROUP BY uid
ORDER BY activity
LIMIT 10;


-- -> Limit: 10 row(s)  (actual time=0.800..0.801 rows=10 loops=1)
--     -> Sort: ((count(distinct testView_temp.msid) + count(distinct testView_temp.lid)) + count(distinct testView_temp.meid)), limit input to 10 row(s) per chunk  (actual time=0.799..0.800 rows=10 loops=1)
--         -> Stream results  (actual time=0.702..0.778 rows=100 loops=1)
--             -> Group aggregate: count(distinct testView_temp.meid), count(distinct testView_temp.lid), count(distinct testView_temp.msid)  (actual time=0.700..0.754 rows=100 loops=1)
--                 -> Sort: testView_temp.uid  (actual time=0.039..0.045 rows=126 loops=1)
--                     -> Table scan on testView_temp  (cost=19.15 rows=148) (actual time=0.001..0.005 rows=126 loops=1)
--                         -> Materialize  (cost=136.93 rows=148) (actual time=0.695..0.708 rows=126 loops=1)
--                             -> Nested loop left join  (cost=136.93 rows=148) (actual time=0.063..0.609 rows=126 loops=1)
--                                 -> Nested loop left join  (cost=85.08 rows=148) (actual time=0.060..0.394 rows=126 loops=1)
--                                     -> Nested loop left join  (cost=45.25 rows=100) (actual time=0.055..0.233 rows=100 loops=1)
--                                         -> Index scan on u using email  (cost=10.25 rows=100) (actual time=0.048..0.060 rows=100 loops=1)
--                                         -> Index lookup on ms using messages_fk_from_user_id (from_user_id=u.id)  (cost=0.25 rows=1) (actual time=0.001..0.002 rows=1 loops=100)
--                                     -> Index lookup on l using likes_fk_user_id (user_id=u.id)  (cost=0.25 rows=1) (actual time=0.001..0.001 rows=1 loops=100)
--                                 -> Index lookup on me using media_fk_user_id (user_id=u.id)  (cost=0.25 rows=1) (actual time=0.001..0.002 rows=1 loops=126)

-- Как оказалось (к тому же решил почитать документацию) данный подход позволяет использовать view в особых дополнителных случаях (агрегатные функции и т.п.).
-- Процесс осуществляется медленнее из-за создания таблицы дополнительной

--                         -> Materialize  (cost=136.93 rows=148) (actual time=0.695..0.708 rows=126 loops=1)


-- В таком случае остается лишь подход с применением временной таблицы, которую можно обновлять при помощи триггеров, который будут осуществлять ее модификацию и заполнение.
-- Такой подход уменьшит нормализованность, но позволит оптимизирровать сложные запросы, использующие большое количество объединений (оптимизация имеет смысл, если
-- они часто используются, как минимум на порядок чаще модификации самой временной таблицы).
-- Создавать ее не стал, так как ограничен во времени.
-- 
-- Если неправильно понял задание, буду ожидать видеоурока.

