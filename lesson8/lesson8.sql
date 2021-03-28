USE vk;

-- Первое задание --

SELECT IF (cnts.male = cnts.female, 'Equals', IF (cnts.male > cnts.female, 'Male', 'Female'))
FROM 	
	(SELECT SUM(IF (p.gender_id = 1, 1, 0)) AS male,
			SUM(IF (p.gender_id = 2, 1, 0)) AS female
	FROM likes l
		JOIN profiles p ON l.user_id = p.user_id) as cnts
;
-- По мне так вышло довольно изящно, аж самому приятно смотреть...


-- Второе задание --

SELECT COUNT(*) AS 'Сумма лайков'
FROM (SELECT * FROM profiles p ORDER BY p.birthday DESC LIMIT 10) as pp
	JOIN likes l ON l.target_id = pp.user_id AND l.target_type_id = 2
;


-- Третье задание --

SELECT 
	CONCAT(p.first_name, ' ', p.last_name) AS 'User', 
	SUM(IF(ISNULL(l.id) AND ISNULL(p2.id) AND ISNULL(f.user_id), 0, 1)) as activities
FROM profiles p
	LEFT JOIN posts p2 ON p2.user_id = p.user_id
	LEFT JOIN likes l ON l.user_id = p.user_id
	LEFT JOIN friendship f 
		ON (f.user_id = p.user_id OR f.friend_id = p.user_id) AND 
		f.status_id = (SELECT id FROM friendship_statuses fs WHERE fs.name = 'Approved')
GROUP BY p.user_id
ORDER BY activities
LIMIT 10;


-- Четвертое задание --


SELECT m.id, CONCAT(p.first_name, ' ', p.last_name),
	SUM(IF(l.like_type = 1, 1, 0)) as 'likes',
	SUM(IF(l.like_type = 0, 1, 0)) as 'dislikes'
FROM media m
	JOIN profiles p ON m.user_id = p.user_id
	LEFT JOIN likes l ON l.target_type_id = m.media_type_id AND l.target_id = m.id
WHERE p.user_id IN(11, 13, 17)
GROUP BY m.id
;
















