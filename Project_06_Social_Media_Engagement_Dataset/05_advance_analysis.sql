-- Advance Analysis
-- For each post, show its likes_count and its rank among all posts on the same platform (RANK() OVER (PARTITION BY platform ORDER BY likes_count DESC)).Hint: don't collapse rows — every post shows its own rank.
-- Solution:

-- For each user, calculate a running total of likes received across their posts, ordered by posted_at. Hint: SUM(likes_count) OVER (PARTITION BY user_id ORDER BY posted_at).
-- Solution:

-- Find the top 3 most-liked posts per platform using a window function inside a CTE. Hint: ROW_NUMBER() OVER (PARTITION BY platform ORDER BY likes_count DESC) in a CTE, then filter WHERE rn <= 3 in the outer query.
-- Solution:

-- For each user's posts, use LAG() to show each post's posted_at next to the previous post's posted_at by that same user, then calculate the number of days between them. Hint: LAG(posted_at) OVER (PARTITION BY user_id ORDER BY posted_at), then subtract dates.
-- Solution:

-- Split all posts into 4 equal-sized groups (quartiles) based on engagement_rate, and show the average likes_count per quartile. Hint: NTILE(4) OVER (ORDER BY engagement_rate), then GROUP BY on the quartile number.
-- Solution:

-- For each content_type, show every post's views_count next to the percentage of that content type's total views the individual post represents. Hint: SUM(views_count) OVER (PARTITION BY content_type) gives the group total; divide the row's own value by it.
-- Solution:

-- Reconstruct full comment reply threads using a recursive CTE — starting from every top-level comment (parent_comment_id IS NULL), find all replies, replies-to-replies, and so on, no matter how deep, showing each comment's comment_id alongside a thread_level number (0 for the original comment, 1 for a direct reply, 2 for a reply-to-a-reply, etc.). Hint: the CTE's anchor query selects top-level comments with thread_level = 0; the recursive part joins comments to the CTE itself on parent_comment_id, adding 1 to thread_level each time, combined with UNION ALL.
-- Solution:

-- For each platform, find the single post with the highest engagement_rate, and show how much higher it is than the platform's average engagement_rate — in the same row. Hint: window function for the platform average, plus a RANK() or MAX() window to isolate the top post; no correlated subquery needed this time.
-- Solution:

-- For each user, show a 3-post moving average of engagement_rate, ordered by posted_at — is a user's engagement trending up or down over their most recent posts? Hint: AVG(engagement_rate) OVER (PARTITION BY user_id ORDER BY posted_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW).
-- Solution:

-- Using FIRST_VALUE() and LAST_VALUE() together (partitioned by user_id, ordered by posted_at), show each user's first post's platform and most recent post's platform side by side on every row — did they ever switch their primary platform? Hint: LAST_VALUE() needs an explicit frame (ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) or it won't behave the way you'd expect by default — worth testing without the frame first to see the surprising result, then adding it to fix it.
-- Solution:
