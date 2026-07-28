-- Join posts to users and list every post's platform, content_type, and the username of its author.
-- Solution:

-- For each platform, count how many posts exist and calculate the average engagement_rate — sorted by average engagement descending.
-- Solution:

-- For each user, count how many total comments they've received across all their posts (join posts → comments, group by the post's owner).
-- Solution:

-- For each user, count how many comments they've written (a different question from #3 — group by comments.user_id directly this time. Think about why these two counts are almost never the same for the same user).
-- Solution:

-- Find the 5 posts with the highest number of rows in the likes table (i.e., the derived like count from the junction table) — not the likes_count column, the actual COUNT().
-- Solution:

-- For each influencer_tier (from users), calculate the total number of posts and the average views_count.
-- Solution:

-- Find every post where the real Kaggle comments_count is higher than the actual number of synthetic comment rows generated for it (join posts to a COUNT() of comments, compare the two).
-- Solution:

-- For each user, show their follower_count and the total number of likes their posts have received combined — sorted by follower count descending. Does a higher follower count reliably mean more likes?
-- Solution:

-- Count how many follows rows exist where the following_id belongs to a Macro tier user — i.e., how many follow relationships are aimed at your biggest accounts.
-- Solution:

-- Find every user who has never posted (appears in users but has zero matching rows in posts) — think back to the anti-join pattern from Project 4, question 5.
-- Solution:
