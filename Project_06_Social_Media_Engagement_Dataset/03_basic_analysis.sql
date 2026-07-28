-- Join posts to users and list every post's platform, content_type, and the username of its author.
-- Solution:
SELECT p.platform, p.content_type, u.username
FROM posts p
JOIN users u ON p.user_id = u.user_id;
-- For each platform, count how many posts exist and calculate the average engagement_rate — sorted by average engagement descending.
-- Solution:
SELECT p.platform, COUNT(*) AS post_count, ROUND(AVG(p.engagement_rate), 2) AS avg_engagement
FROM posts p
GROUP BY p.platform
ORDER BY avg_engagement DESC;
-- For each user, count how many total comments they've received across all their posts (join posts → comments, group by the post's owner).
-- Solution:
SELECT u.username, COUNT(c.comment_id) AS total_comments
FROM users u
JOIN posts p ON u.user_id = p.user_id
JOIN comments c ON p.post_id = c.post_id
GROUP BY u.username;
-- For each user, count how many comments they've written (a different question from #3 — group by comments.user_id directly this time.
-- Think about why these two counts are almost never the same for the same user).
-- Answer: This is because a user can receive comments on their posts (from other users) but may not have written any comments themselves.
-- Solution:
SELECT u.username, COUNT(c.comment_id) AS comments_written
FROM users u
JOIN comments c ON u.user_id = c.user_id
GROUP BY u.username;
-- Find the 5 posts with the highest number of rows in the likes table (i.e., the derived like count from the junction table) — not the likes_count column, the actual COUNT().
-- Solution:
SELECT p.post_id, COUNT(l.user_id) AS like_count
FROM posts p
JOIN likes l ON p.post_id = l.post_id
GROUP BY p.post_id
ORDER BY like_count DESC
LIMIT 5;
-- For each influencer_tier (from users), calculate the total number of posts and the average views_count.
-- Solution:
SELECT u.influencer_tier, COUNT(p.post_id) AS total_posts, ROUND(AVG(p.views_count), 2) AS avg_views
FROM users u
JOIN posts p ON u.user_id = p.user_id
GROUP BY u.influencer_tier;
-- Find every post where the real Kaggle comments_count is higher than the actual number of synthetic comment rows generated for it (join posts to a COUNT() of comments, compare the two).
-- Solution:
SELECT p.post_id, p.comments_count AS kaggle_comments_count, COUNT(c.comment_id) AS actual_comments_count
FROM posts p
JOIN comments c ON p.post_id = c.post_id
GROUP BY p.post_id, p.comments_count
HAVING p.comments_count > COUNT(c.comment_id);
-- For each user, show their follower_count and the total number of likes their posts have received combined — sorted by follower count descending. Does a higher follower count reliably mean more likes?
-- Solution:
SELECT u.username, u.follower_count, COUNT(l.user_id) AS total_likes
FROM users u
JOIN posts p ON u.user_id = p.user_id
JOIN likes l ON p.post_id = l.post_id
GROUP BY u.username, u.follower_count
ORDER BY u.follower_count DESC;
-- Count how many follows rows exist where the following_id belongs to a Macro tier user — i.e., how many follow relationships are aimed at your biggest accounts.
-- Solution:
SELECT COUNT(*) AS macro_follows
FROM follows f
JOIN users u ON f.following_id = u.user_id
WHERE u.influencer_tier = 'Macro';
-- Find every user who has never posted (appears in users but has zero matching rows in posts) — think back to the anti-join pattern from Project 4, question 5.
-- Solution:
SELECT u.username
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
WHERE p.post_id IS NULL;