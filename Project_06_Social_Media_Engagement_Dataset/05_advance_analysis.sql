-- Advance Analysis
-- For each post, show its likes_count and its rank among all posts on the same platform (RANK() OVER (PARTITION BY platform ORDER BY likes_count DESC)).Hint: don't collapse rows — every post shows its own rank.
-- Solution:
SELECT
    post_id,
    platform,
    likes_count,
    RANK() OVER (PARTITION BY platform ORDER BY likes_count DESC) AS platform_likes_rank
FROM posts
ORDER BY platform, platform_likes_rank;
-- Analysis
-- What this does: for every single post, it looks at all the OTHER
-- posts on the same platform and figures out where this post ranks
-- by likes. Instagram posts only get compared against Instagram posts,
-- Twitter posts only against Twitter posts, etc. No rows get hidden —
-- every post keeps its own row and just gets a rank number attached.


-- For each user, calculate a running total of likes received across their posts, ordered by posted_at. Hint: SUM(likes_count) OVER (PARTITION BY user_id ORDER BY posted_at).
-- Solution:
SELECT
    user_id,
    post_id,
    posted_at,
    likes_count,
    SUM(likes_count) OVER (PARTITION BY user_id ORDER BY posted_at) AS running_total_likes
FROM posts
ORDER BY user_id, posted_at;
-- Analysis --
-- What this does: imagine reading through one user's posts in
-- chronological order and keeping a mental "likes so far" counter
-- that goes up with each post. That's exactly what this query builds
-- — a cumulative sum that resets separately for each user
-- (PARTITION BY user_id) and only adds up in time order (ORDER BY
-- posted_at inside the OVER clause).


-- Find the top 3 most-liked posts per platform using a window function inside a CTE. Hint: ROW_NUMBER() OVER (PARTITION BY platform ORDER BY likes_count DESC) in a CTE, then filter WHERE rn <= 3 in the outer query.
-- Solution:
WITH ranked_posts AS (
    SELECT
        post_id,
        platform,
        likes_count,
        ROW_NUMBER() OVER (PARTITION BY platform ORDER BY likes_count DESC) AS rn
    FROM posts
)
SELECT post_id, platform, likes_count, rn
FROM ranked_posts
WHERE rn <= 3
ORDER BY platform, rn;

-- Analysis --
-- What this does: this is the classic "top-N per group" problem.
-- You can't just say "WHERE rank <= 3" in a normal query, because
-- the rank doesn't exist as a real column yet — you have to calculate
-- it first (in a CTE), and only THEN filter on it in a second step.
-- ROW_NUMBER() gives every post on a platform a unique position
-- (1st, 2nd, 3rd...) with no ties, ordered by likes, and we simply
-- keep the first three per platform.


-- For each user's posts, use LAG() to show each post's posted_at next to the previous post's posted_at by that same user, then calculate the number of days between them. Hint: LAG(posted_at) OVER (PARTITION BY user_id ORDER BY posted_at), then subtract dates.
-- Solution:
SELECT
    user_id,
    post_id,
    posted_at,
    LAG(posted_at) OVER (PARTITION BY user_id ORDER BY posted_at) AS previous_post_at,
    EXTRACT(DAY FROM posted_at - LAG(posted_at) OVER (PARTITION BY user_id ORDER BY posted_at)) AS days_since_previous_post
FROM posts
ORDER BY user_id, posted_at;

-- Analysis --
-- What this does: LAG() reaches BACKWARD one row and pulls in a value
-- from it — here, the previous post's date, for that same user. Once
-- we have "this post's date" and "the previous post's date" sitting
-- side by side in the same row, a normal subtraction gives us the
-- number of days between them. The very first post for each user will
-- show NULL, because there's no "previous" post to compare against.


-- Split all posts into 4 equal-sized groups (quartiles) based on engagement_rate, and show the average likes_count per quartile. Hint: NTILE(4) OVER (ORDER BY engagement_rate), then GROUP BY on the quartile number.
-- Solution:
WITH quartiles AS (
    SELECT
        post_id,
        engagement_rate,
        likes_count,
        NTILE(4) OVER (ORDER BY engagement_rate) AS engagement_quartile
    FROM posts
)
SELECT
    engagement_quartile,
    COUNT(*) AS post_count,
    ROUND(AVG(likes_count), 2) AS avg_likes
FROM quartiles
GROUP BY engagement_quartile
ORDER BY engagement_quartile;

-- Analysis --
-- What this does: NTILE(4) lines up every post by engagement_rate,
-- low to high, then slices that line into 4 equal-sized chunks and
-- labels each post with which chunk (1, 2, 3, or 4) it landed in —
-- quartile 1 is the lowest-engagement posts, quartile 4 the highest.
-- We do this inside a CTE first because we need that quartile label
-- to exist as a real column before we can GROUP BY it in the next step.


-- For each content_type, show every post's views_count next to the percentage of that content type's total views the individual post represents. Hint: SUM(views_count) OVER (PARTITION BY content_type) gives the group total; divide the row's own value by it.
-- Solution:
SELECT
    post_id,
    content_type,
    views_count,
    SUM(views_count) OVER (PARTITION BY content_type) AS content_type_total_views,
    ROUND(100.0 * views_count / SUM(views_count) OVER (PARTITION BY content_type), 2) AS pct_of_content_type_views
FROM posts
ORDER BY content_type, pct_of_content_type_views DESC;

-- Analysis --
-- What this does: SUM(views_count) OVER (PARTITION BY content_type),
-- with no ORDER BY inside OVER(), gives every post the GRAND TOTAL
-- views for its whole content type (e.g. all "Carousel" posts added
-- together) — not a running total, the full group sum, repeated on
-- every row in that group. Once we have that total sitting next to
-- the post's own views, dividing gives us the percentage share.


-- Reconstruct full comment reply threads using a recursive CTE — starting from every top-level comment (parent_comment_id IS NULL), find all replies, replies-to-replies, and so on, no matter how deep, showing each comment's comment_id alongside a thread_level number (0 for the original comment, 1 for a direct reply, 2 for a reply-to-a-reply, etc.). Hint: the CTE's anchor query selects top-level comments with thread_level = 0; the recursive part joins comments to the CTE itself on parent_comment_id, adding 1 to thread_level each time, combined with UNION ALL.
-- Solution:
WITH RECURSIVE comment_thread AS (
    -- Anchor: top-level comments (no parent)
    SELECT
        comment_id,
        post_id,
        user_id,
        parent_comment_id,
        body,
        created_at,
        0 AS thread_level
    FROM comments
    WHERE parent_comment_id IS NULL
 
    UNION ALL
 
    -- Recursive step: find replies to comments we already found
    SELECT
        c.comment_id,
        c.post_id,
        c.user_id,
        c.parent_comment_id,
        c.body,
        c.created_at,
        ct.thread_level + 1
    FROM comments c
    JOIN comment_thread ct ON c.parent_comment_id = ct.comment_id
)
SELECT *
FROM comment_thread
ORDER BY post_id, thread_level, comment_id;

-- Analysis --
-- What this does: a recursive CTE has two halves joined by UNION ALL.
--
--   1) The ANCHOR (runs once): grab every top-level comment — one
--      with no parent — and label it thread_level = 0. This is the
--      starting point of every thread.
--
--   2) The RECURSIVE part (runs over and over): find every comment
--      whose parent_comment_id matches a comment_id we already found
--      in the previous round, and label it one level deeper
--      (thread_level + 1). Postgres keeps re-running this step,
--      feeding its own previous output back into itself, until a
--      round comes back with zero new matches — that's what "recursive"
--      means here: it keeps climbing down the reply chain, however
--      many levels deep it goes, without you having to know the depth
--      in advance.
--
-- Real-world parallel: this is the exact logic that renders nested
-- comment threads on Reddit, YouTube, or Instagram.


-- For each platform, find the single post with the highest engagement_rate, and show how much higher it is than the platform's average engagement_rate — in the same row. Hint: window function for the platform average, plus a RANK() or MAX() window to isolate the top post; no correlated subquery needed this time.
-- Solution:
WITH platform_stats AS (
    SELECT
        post_id,
        platform,
        engagement_rate,
        AVG(engagement_rate) OVER (PARTITION BY platform) AS platform_avg_engagement,
        RANK() OVER (PARTITION BY platform ORDER BY engagement_rate DESC) AS engagement_rank
    FROM posts
)
SELECT
    post_id,
    platform,
    engagement_rate,
    ROUND(platform_avg_engagement, 2) AS platform_avg_engagement,
    ROUND(engagement_rate - platform_avg_engagement, 2) AS diff_from_platform_avg
FROM platform_stats
WHERE engagement_rank = 1
ORDER BY platform;

-- Analysis --
-- What this does: two window functions doing two different jobs in
-- the same CTE — AVG() OVER (PARTITION BY platform) attaches the
-- platform's average engagement to every post in that platform, while
-- RANK() OVER (PARTITION BY platform ORDER BY engagement_rate DESC)
-- finds which single post is #1 in that platform. We calculate both
-- first, then filter down to just the #1 rows in the outer query —
-- same "calculate first, filter second" idea as Q3.


-- For each user, show a 3-post moving average of engagement_rate, ordered by posted_at — is a user's engagement trending up or down over their most recent posts? Hint: AVG(engagement_rate) OVER (PARTITION BY user_id ORDER BY posted_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW).
-- Solution:
SELECT
    user_id,
    post_id,
    posted_at,
    engagement_rate,
    ROUND(
        AVG(engagement_rate) OVER (
            PARTITION BY user_id
            ORDER BY posted_at
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moving_avg_3_posts
FROM posts
ORDER BY user_id, posted_at;

-- Analysis --
-- What this does: a moving average only looks at a small, sliding
-- "window" of nearby rows instead of the whole history — here, each
-- post's own engagement_rate averaged together with the engagement_rate
-- of the 2 posts immediately before it (in time order, per user).
-- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW is what defines that
-- sliding window size (3 rows total: 2 before + the current one).
-- This smooths out noise and shows whether a user's engagement is
-- trending up or down recently, rather than being skewed by one
-- unusually good or bad post.


-- Using FIRST_VALUE() and LAST_VALUE() together (partitioned by user_id, ordered by posted_at), show each user's first post's platform and most recent post's platform side by side on every row — did they ever switch their primary platform? Hint: LAST_VALUE() needs an explicit frame (ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) or it won't behave the way you'd expect by default — worth testing without the frame first to see the surprising result, then adding it to fix it.
-- Solution:
SELECT DISTINCT
    user_id,
    FIRST_VALUE(platform) OVER (
        PARTITION BY user_id ORDER BY posted_at
    ) AS first_platform,
    LAST_VALUE(platform) OVER (
        PARTITION BY user_id ORDER BY posted_at
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS latest_platform
FROM posts
ORDER BY user_id;

-- Analysis --
-- What this does: FIRST_VALUE() grabs the platform from the earliest
-- post (by posted_at) for each user, and LAST_VALUE() grabs the
-- platform from their most recent post — both attached to every row
-- for that user. LAST_VALUE() needs an EXPLICIT frame
-- (ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING), because
-- by default a window function's frame only looks "backward" up to
-- the current row — without stating the frame explicitly, LAST_VALUE()
-- would quietly just return the CURRENT row's own value on every row,
-- not the true final post, which is a common silent mistake.
-- DISTINCT is used because every post-row for a user would otherwise
-- repeat the identical first/last platform values.
