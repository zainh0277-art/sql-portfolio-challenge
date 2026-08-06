# Project 6: Social Media Platform Backend

A SQL project modeling the backend of a social media platform — users, posts, comments, likes, and follows — focused on relationship-heavy schema design and the query techniques that come with it: junction tables, self-referencing foreign keys, window functions, and recursive CTEs.

## Overview

Unlike Projects 4 and 5, which modeled single transactional events (a hospital visit, a hotel stay), this project is built around how entities *connect* to each other. A user follows other users. A user likes many posts, and a post is liked by many users. A comment can reply to another comment, which can reply to another comment, arbitrarily deep. None of that fits into simple one-to-many foreign keys — it requires junction tables and self-referencing relationships, which is the core skill this project is built to practice.

## Dataset — What's Real vs. Synthetic

This is the one project in the series where the data isn't fully sourced from a single dataset, and that's worth documenting clearly.

**Real (Kaggle):** `posts` — 150 rows sampled from the Social Media Engagement Dataset (`aviral342/social-media-engagement-dataset`), stratified by platform. All engagement numbers (`likes_count`, `comments_count`, `shares_count`, `views_count`, `saves_count`, `engagement_rate`, etc.) are the genuine values from the source file, untouched.

**Synthetic (generated for this project):** `users`, `comments`, `likes`, and `follows`. No free, practically-sized public dataset exists with real row-level user/post/comment/like/follow event data — the real platforms don't expose that publicly, and the closest real alternative found (Reddit submissions/comments) turned out not to have the needed fields either. Rather than force a fake relational structure onto data that didn't support it, the decision was made to keep the real Kaggle post data as the anchor and build a realistic, referentially-consistent synthetic layer around it:

- 200 synthetic users, with follower counts drawn from a lognormal distribution so the population skews toward small accounts with a few large ones, matching real platform demographics.
- Posts assigned to users with weighted randomness, so posting frequency isn't uniform.
- Comments, likes, and follows scaled proportionally from each post's real engagement numbers, so posts with higher real engagement get proportionally more synthetic interaction rows.

Every foreign key relationship across all five tables has been integrity-checked (no orphaned rows, no duplicate composite keys, no self-follows).

## Schema

**users**
`user_id` (PK), `username`, `follower_count`, `influencer_tier`, `is_verified`, `account_created_date`

**posts**
`post_id` (PK), `kaggle_post_id`, `user_id` (FK → users), `posted_at`, `platform`, `content_type`, `category`, `likes_count`, `comments_count`, `shares_count`, `views_count`, `saves_count`, `engagement_rate`, `hour_of_day`, `day_of_week`, `hashtag_count`, `content_length`, `sentiment`, `author_follower_count_snapshot`, `author_tier_snapshot`, `author_verified_snapshot`, `has_media`

The `author_*_snapshot` columns intentionally keep the original Kaggle per-post values separate from the user's current profile in `users` — a user's follower count today isn't the same as it was when they made a given post, so the two are stored independently rather than merged.

**comments**
`comment_id` (PK), `post_id` (FK → posts), `user_id` (FK → users), `parent_comment_id` (self-referencing FK → comments, NULL for top-level comments), `body`, `created_at`

**likes**
`user_id` (FK → users), `post_id` (FK → posts), `created_at` — composite primary key on `(user_id, post_id)`, enforcing that a user can only like a given post once.

**follows**
`follower_id` (FK → users), `following_id` (FK → users), `followed_at` — composite primary key on `(follower_id, following_id)`, self-referencing on `users`, with a `CHECK` constraint preventing a user from following themselves.

## Files

| File | Description
## -- 01_schema.sql --
 Table definitions, constraints, composite keys, foreign keys, and indexes 
## -- 02_inserts.sql --
 Real posts data + synthetic users/comments/likes/follows (~5,000 rows total)
## -- 03_basic_analysis.sql -- 
Join ladders across the relationship tables, junction-table counting
## -- 04_intermediate_analysis.sql --
 Multi-table joins, GROUP BY/HAVING, correlated subqueries, self-joins, anti-joins
## -- advance_analysis.sql --
  Window functions (RANK, LAG, NTILE, moving averages), recursive CTEs for comment threading 

## Concepts Practiced

- Normalizing a flat engagement file into a relational schema
- One-to-many relationships (`users` → `posts`)
- Many-to-many relationships via junction tables (`likes`)
- Self-referencing foreign keys (`follows` on `users`, `parent_comment_id` on `comments`)
- Composite primary keys
- Deriving metrics from relationship rows (`COUNT()` over a junction table) rather than stored columns
- Self-joins for relationship traversal (mutual follows, comment reply pairs)
- Anti-joins for finding unmatched records (users with no comments, users who follow but never like)
- Window functions: `RANK()`, `ROW_NUMBER()`, `NTILE()`, `LAG()`, `FIRST_VALUE()`, `LAST_VALUE()`, running totals, moving averages
- Recursive CTEs for reconstructing arbitrarily deep comment reply threads
- Top-N-per-group analysis

## How to Run

1. Run `01_schema.sql` to create the tables.
2. Run `02_inserts.sql` to load the data.
3. Run `basic_analysis.sql`, then `intermediate_analysis.sql`, then `advance_analysis.sql`, in order.

Built in PostgreSQL (via VS Code / pgAdmin).