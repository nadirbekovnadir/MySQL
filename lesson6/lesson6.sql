USE vk;

-- Добавление дополнительных связей --

ALTER TABLE friendship
  ADD CONSTRAINT friendship_fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  ADD CONSTRAINT profiles_fk_friend_id
    FOREIGN KEY (friend_id) REFERENCES users(id) ON DELETE CASCADE,
  ADD CONSTRAINT profiles_fk_status_id
    FOREIGN KEY (status_id) REFERENCES friendship_statuses(id);

ALTER TABLE likes
  ADD CONSTRAINT likes_fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  ADD CONSTRAINT likes_fk_target_id
    FOREIGN KEY (target_id) REFERENCES users(id) ON DELETE CASCADE,
  ADD CONSTRAINT likes_fk_target_type_id
    FOREIGN KEY (target_type_id) REFERENCES target_types(id);

ALTER TABLE media
  ADD CONSTRAINT media_fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  ADD CONSTRAINT media_fk_media_type_id
    FOREIGN KEY (media_type_id) REFERENCES media_types(id);

ALTER TABLE posts
  ADD CONSTRAINT posts_fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  ADD CONSTRAINT posts_fk_community_id
    FOREIGN KEY (community_id) REFERENCES communities(id);


-- Первое задание --

SELECT IF(male.cnt = female.cnt, 'Equals', IF(male.cnt > female.cnt, 'Male', 'Female')) 
	FROM 
		(SELECT COUNT(*) cnt FROM likes l 
			WHERE user_id IN(SELECT user_id FROM profiles p WHERE gender_id = (SELECT id FROM gender WHERE gender_info LIKE 'Male'))) AS male,
		(SELECT COUNT(*) cnt FROM likes l 
			WHERE user_id IN(SELECT user_id FROM profiles p WHERE gender_id = (SELECT id FROM gender WHERE gender_info LIKE 'Female'))) AS female
	;
	

-- Второе задание --

SELECT * FROM profiles p ORDER BY p.birthday DESC LIMIT 10;

SELECT COUNT(*) 
	FROM likes l 
	WHERE 
		target_id IN(SELECT pp.user_id FROM (SELECT * FROM profiles p ORDER BY p.birthday DESC LIMIT 10) pp)
		AND
		target_type_id = (SELECT id FROM target_types tt WHERE tt.name = 'users')
	;
	

-- Третье задание --

SELECT 
	CONCAT(p.first_name, ' ', p.last_name),
	(SELECT SUM(cnt) 
	FROM
		(SELECT COUNT(*) cnt FROM posts p2 WHERE p2.user_id = p.user_id 
		UNION ALL
		SELECT COUNT(*) FROM likes l2 WHERE l2.user_id = p.user_id 
		UNION ALL
		SELECT COUNT(*) FROM friendship f
			WHERE 
				(f.user_id = p.user_id  OR f.friend_id = p.user_id) AND 
				f.status_id = (SELECT id FROM friendship_statuses fs WHERE fs.name = 'Approved')) activity_cnt) activity_sum
FROM profiles p
ORDER BY activity_sum
LIMIT 10;
	
	
	
	
	
	
	
	
	
	

