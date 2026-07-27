-- Project 6: Social Media Platform Backend
-- 01_schema.sql
--
-- Posts data source: Kaggle - Social Media Engagement Dataset
-- (aviral342/social-media-engagement-dataset) - REAL DATA

DROP TABLE IF EXISTS follows;
DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

-- 1. Users (synthetic)
CREATE TABLE users (
    user_id                SERIAL PRIMARY KEY,
    username                VARCHAR(50) NOT NULL UNIQUE,
    follower_count          INT NOT NULL CHECK (follower_count >= 0),
    influencer_tier         VARCHAR(15) NOT NULL CHECK (influencer_tier IN ('Nano','Micro','Mid-tier','Macro')),
    is_verified              BOOLEAN NOT NULL,
    account_created_date    DATE NOT NULL
);

-- 2. Posts (real Kaggle engagement data + synthetic author link)
-- Follower_count/tier/verified on this table are the ORIGINAL per-post
-- values from Kaggle, kept as a "snapshot at time of posting" rather
-- than merged into the user's current profile values, since those two
-- things can legitimately differ over time.
CREATE TABLE posts (
    post_id                     SERIAL PRIMARY KEY,
    kaggle_post_id                VARCHAR(20) NOT NULL,     -- original Post_ID from the source file
    user_id                     INT NOT NULL REFERENCES users(user_id),
    posted_at                    TIMESTAMP NOT NULL,
    platform                     VARCHAR(15) NOT NULL,
    content_type                 VARCHAR(20) NOT NULL,
    category                     VARCHAR(20) NOT NULL,
    likes_count                  INT NOT NULL CHECK (likes_count >= 0),
    comments_count                INT NOT NULL CHECK (comments_count >= 0),
    shares_count                 INT NOT NULL CHECK (shares_count >= 0),
    views_count                  INT NOT NULL CHECK (views_count >= 0),
    saves_count                  INT NOT NULL CHECK (saves_count >= 0),
    engagement_rate               DECIMAL(6,2) NOT NULL,
    hour_of_day                  INT NOT NULL CHECK (hour_of_day BETWEEN 0 AND 23),
    day_of_week                  VARCHAR(10) NOT NULL,
    hashtag_count                 INT NOT NULL CHECK (hashtag_count >= 0),
    content_length                INT NOT NULL CHECK (content_length >= 0),
    sentiment                    VARCHAR(10) NOT NULL CHECK (sentiment IN ('Positive','Negative','Neutral')),
    author_follower_count_snapshot  INT NOT NULL,
    author_tier_snapshot           VARCHAR(15) NOT NULL,
    author_verified_snapshot        BOOLEAN NOT NULL,
    has_media                    BOOLEAN NOT NULL
);

-- 3. Comments (synthetic; parent_comment_id is self-referencing for reply threads)
CREATE TABLE comments (
    comment_id            SERIAL PRIMARY KEY,
    post_id                INT NOT NULL REFERENCES posts(post_id) ON DELETE CASCADE,
    user_id                INT NOT NULL REFERENCES users(user_id),
    parent_comment_id       INT REFERENCES comments(comment_id),   -- NULL = top-level comment
    body                    VARCHAR(200) NOT NULL,
    created_at              TIMESTAMP NOT NULL
);

-- 4. Likes (synthetic; many-to-many junction table between users and posts)
CREATE TABLE likes (
    user_id      INT NOT NULL REFERENCES users(user_id),
    post_id      INT NOT NULL REFERENCES posts(post_id) ON DELETE CASCADE,
    created_at   TIMESTAMP NOT NULL,
    PRIMARY KEY (user_id, post_id)     -- composite key: a user can like a given post only once
);

-- 5. Follows (synthetic; self-referencing many-to-many junction table on users)
CREATE TABLE follows (
    follower_id    INT NOT NULL REFERENCES users(user_id),
    following_id   INT NOT NULL REFERENCES users(user_id),
    followed_at    TIMESTAMP NOT NULL,
    PRIMARY KEY (follower_id, following_id),
    CHECK (follower_id <> following_id)   -- a user cannot follow themselves
);

-- Indexes for common analytical queries
CREATE INDEX idx_posts_user            ON posts(user_id);
CREATE INDEX idx_posts_platform        ON posts(platform);
CREATE INDEX idx_comments_post         ON comments(post_id);
CREATE INDEX idx_comments_user         ON comments(user_id);
CREATE INDEX idx_comments_parent       ON comments(parent_comment_id);
CREATE INDEX idx_likes_post            ON likes(post_id);
CREATE INDEX idx_follows_following     ON follows(following_id);