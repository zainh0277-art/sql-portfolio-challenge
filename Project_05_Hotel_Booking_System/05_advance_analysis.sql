-- Advanced Analysis Queries --
-- Running total revenue by hotel over time. For each hotel, calculate a running (cumulative) total of adr * (stays_in_weekend_nights + stays_in_week_nights) ordered by arrival_date, for non-cancelled bookings only. Hint: window function — SUM(...) OVER (PARTITION BY hotel_id ORDER BY arrival_date).
-- Solution:
SELECT
    h.hotel_name,
    b.arrival_date,
    SUM(b.adr * (b.stays_in_weekend_nights + b.stays_in_week_nights)) OVER (PARTITION BY b.hotel_id ORDER BY b.arrival_date) AS running_total_revenue
FROM
    hotels h
    JOIN bookings b ON h.hotel_id = b.hotel_id
WHERE
    b.is_canceled = FALSE
ORDER BY
    h.hotel_name,
    b.arrival_date;
-- Rank bookings by ADR within each market segment. For every booking, show its rank (1 = highest adr) within its own market_segment — without collapsing rows like GROUP BY would. Hint: RANK() or DENSE_RANK() OVER (PARTITION BY market_segment ORDER BY adr DESC).
-- Soolution:
SELECT
    b.booking_id,
    b.market_segment,
    b.adr,
    RANK() OVER (PARTITION BY b.market_segment ORDER BY b.adr DESC) AS adr_rank_within_segment
FROM
    bookings b
ORDER BY
    b.market_segment,
    b.adr DESC;
-- Month-over-month change in booking volume. For each hotel, show total bookings per month and the change from the previous month. Hint: build a monthly count first (CTE), then use LAG() to pull the prior month's value into the same row.
-- Solution:
WITH monthly_bookings AS (
    SELECT
        h.hotel_name,
        DATE_TRUNC('month', b.arrival_date) AS month,
        COUNT(*) AS total_bookings
    FROM
        hotels h
        JOIN bookings b ON h.hotel_id = b.hotel_id
    GROUP BY
        h.hotel_name,
        DATE_TRUNC('month', b.arrival_date)
)
SELECT
    mb.hotel_name,
    mb.month,
    mb.total_bookings,
    mb.total_bookings - LAG(mb.total_bookings) OVER (PARTITION BY mb.hotel_name ORDER BY mb.month) AS booking_change
FROM
    monthly_bookings mb
ORDER BY
    mb.hotel_name,
    mb.month;
-- Top 3 highest-ADR bookings per country. Find the 3 bookings with the highest adr for each country — a classic "top-N per group" problem. Hint: ROW_NUMBER() OVER (PARTITION BY country ORDER BY adr DESC) inside a CTE, then filter WHERE row_num <= 3 in the outer query — a plain WHERE can't filter on a window function directly.
-- Solution:
WITH ranked_bookings AS (
    SELECT
        b.booking_id,
        b.country,
        b.adr,
        ROW_NUMBER() OVER (PARTITION BY b.country ORDER BY b.adr DESC) AS row_num
    FROM
        bookings b
)
SELECT
    rb.booking_id,
    rb.country,
    rb.adr,
    rb.row_num
FROM
    ranked_bookings rb
WHERE
    rb.row_num <= 3
ORDER BY
    rb.country,
    rb.adr DESC;
-- Identify guests who are "at risk" using a moving pattern. For each market_segment, calculate the 3-booking moving average of adr ordered by arrival_date, to see if pricing is trending up or down within a segment. Hint: AVG(adr) OVER (PARTITION BY market_segment ORDER BY arrival_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW).
-- Solution:
SELECT
    b.market_segment,
    b.arrival_date,
    ROUND(AVG(b.adr) OVER (PARTITION BY b.market_segment ORDER BY b.arrival_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_adr
FROM
    bookings b
ORDER BY
    b.market_segment,
    b.arrival_date;
-- Percentage of total revenue each market segment contributes. For each market_segment, show its total revenue and what percentage that is of the grand total — in the same query, no separate lookup. Hint: SUM(...) OVER () with no PARTITION BY gives you the grand total alongside the grouped rows.
-- Solution:
SELECT
    b.market_segment,
    ROUND(SUM(b.adr * (b.stays_in_weekend_nights + b.stays_in_week_nights)), 2) AS total_revenue,
    ROUND(SUM(b.adr * (b.stays_in_weekend_nights + b.stays_in_week_nights)) * 100.0 / SUM(SUM(b.adr * (b.stays_in_weekend_nights + b.stays_in_week_nights))) OVER (), 2) || '%' AS revenue_percentage_of_total
FROM
    bookings b
GROUP BY
    b.market_segment
ORDER BY
    total_revenue DESC;
-- Find the gap between a hotel's best and worst month. Using a CTE that aggregates bookings by hotel and month, find the difference between each hotel's highest-volume month and lowest-volume month. Hint: build the monthly summary as a CTE, then aggregate again on top of it with MAX() - MIN().
-- Solution:
WITH monthly_summary AS (
    SELECT
        h.hotel_name,
        DATE_TRUNC('month', b.arrival_date) AS month,
        COUNT(*) AS total_bookings
    FROM
        hotels h
        JOIN bookings b ON h.hotel_id = b.hotel_id
    GROUP BY
        h.hotel_name,
        DATE_TRUNC('month', b.arrival_date)
)
SELECT
    ms.hotel_name,
    MAX(ms.total_bookings) - MIN(ms.total_bookings) AS booking_gap
FROM
    monthly_summary ms
GROUP BY
    ms.hotel_name
ORDER BY
    booking_gap DESC;
-- Classify each booking as above/below its hotel's average ADR. For every individual booking, add a column showing whether its adr is above or below the average adr for that specific hotel — one row per booking, not grouped. Hint: correlated subquery (which you've already practiced) OR AVG(adr) OVER (PARTITION BY hotel_id) — try both and compare readability/performance.
-- Solution:
SELECT
    b.booking_id,
    b.hotel_id,
    b.adr,
    CASE
        WHEN b.adr > AVG(b.adr) OVER (PARTITION BY b.hotel_id) THEN 'Above Average'
        WHEN b.adr < AVG(b.adr) OVER (PARTITION BY b.hotel_id) THEN 'Below Average'
        ELSE 'Average'
    END AS adr_classification
FROM
    bookings b
ORDER BY
    b.hotel_id,
    b.adr DESC;
-- Find consecutive months where cancellation rate increased. Using monthly cancellation rate as a CTE, find every month where the cancellation rate was higher than the previous month's. Hint: same LAG() pattern as question 3, but comparing a calculated rate instead of a raw count.
-- Solution:
WITH monthly_cancellation_rate AS (
    SELECT
        DATE_TRUNC('month', arrival_date) AS month,
        ROUND(COUNT(CASE WHEN is_canceled = TRUE THEN 1 END) * 100.0 / COUNT(*), 2) AS cancellation_rate
    FROM
        bookings
    GROUP BY
        DATE_TRUNC('month', arrival_date)
)
SELECT
    mcr.month,
    mcr.cancellation_rate,
    mcr.cancellation_rate - LAG(mcr.cancellation_rate) OVER (ORDER BY mcr.month) AS cancellation_rate_change
FROM
    monthly_cancellation_rate mcr
-- Segment customers into ADR quartiles. Split all bookings into 4 equal-sized groups (quartiles) based on adr, and show the average total_of_special_requests per quartile — do higher-paying bookings request more? Hint: NTILE(4) OVER (ORDER BY adr) assigns each row a quartile number 1-4; then GROUP BY on that quartile number.
-- Solution:
WITH adr_quartiles AS (
    SELECT
        booking_id,
        adr,
        total_of_special_requests,
        NTILE(4) OVER (ORDER BY adr) AS adr_quartile
    FROM
        bookings
)
SELECT
    aq.adr_quartile,
    ROUND(AVG(aq.total_of_special_requests),2) || '%' AS avg_special_requests
FROM
    adr_quartiles aq
GROUP BY
    aq.adr_quartile
ORDER BY
    aq.adr_quartile;