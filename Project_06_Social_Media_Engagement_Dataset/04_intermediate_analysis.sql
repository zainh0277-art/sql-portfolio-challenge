-- Join users + posts + comments to find, for each post, the username of the author and the total number of comments it received — but only show posts with more than 5 comments (HAVING).
-- Solution:
SELECT p.post_id, u.username, COUNT(c.comment_id) AS total_comments
FROM posts p
JOIN users u ON p.user_id = u.user_id
JOIN comments c ON p.post_id = c.post_id
GROUP BY p.post_id, u.username
HAVING COUNT(c.comment_id) > 5;

--For each platform, calculate the average follower_count of the users posting there (join posts → users, GROUP BY platform) — which platform attracts the biggest accounts?
-- Solution:
SELECT p.platform, ROUND(AVG(u.follower_count), 2) AS avg_follower_count
FROM posts p
JOIN users u ON p.user_id = u.user_id
GROUP BY p.platform
ORDER BY avg_follower_count DESC;

-- Using an anti-join, find every user who has posted at least once but has never received a single comment on any of their posts.
-- Solution:
SELECT u.user_id, u.username
FROM users u
JOIN posts p ON u.user_id = p.user_id
LEFT JOIN comments c ON p.post_id = c.post_id
WHERE c.comment_id IS NULL;

-- Join comments to itself (self-join on parent_comment_id) to find every comment that has at least one reply, showing the original comment's body next to the reply's body.
-- Solution:
SELECT 

-- For each influencer_tier, calculate the total number of likes received across all their posts and the total number of posts — but only include tiers where the average likes per post exceeds 500 (HAVING on a calculated ratio).
-- Solution:
