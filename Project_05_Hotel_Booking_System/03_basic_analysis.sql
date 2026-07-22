-- Intermediate --
-- Find the cancellation rate (is_canceled = TRUE as a percentage of total bookings) for each hotel_id, joined against hotels for the readable name.
-- Solution:
SELECT
    h.hotel_id AS hotel_id
    , h.hotel_name AS hotel_name
    , COUNT(b.*) AS total_bookings
    , SUM(CASE WHEN b.is_canceled = TRUE THEN 1 ELSE 0 END) AS canceled_bookings
    , ROUND(SUM(CASE WHEN b.is_canceled = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_percentage
FROM bookings b
JOIN hotels h ON b.hotel_id = h.hotel_id
GROUP BY h.hotel_id, h.hotel_name
-- For each market_segment, find the average lead_time and average adr — which segment books furthest in advance, and which pays the most per night?
-- Solution:
SELECT
    b.market_segment,
    ROUND(AVG(b.lead_time), 2) AS average_lead_time,
    ROUND(AVG(b.adr), 2) AS average_adr
FROM bookings b
GROUP BY b.market_segment
-- Find the top 10 country values by booking count — but first decide how you're handling the 14 NULL countries in the result (excluded entirely? shown as 'Unknown'? your call, just be explicit about it).
-- Solution:
SELECT
    COALESCE(b.country, 'Unknown') AS country,
    COUNT(*) AS booking_count
FROM bookings b
WHERE b.country IS NOT NULL
GROUP BY COALESCE(b.country, 'Unknown')
ORDER BY booking_count DESC
LIMIT 10;
-- For each arrival_date month (extract month from the date), count total bookings and cancellations, and calculate the cancellation rate — is there a seasonal pattern?
-- Solution:
SELECT
    EXTRACT(MONTH FROM b.arrival_date) AS arrival_month,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN b.is_canceled = TRUE THEN 1 ELSE 0 END) AS canceled_bookings,
    ROUND(SUM(CASE WHEN b.is_canceled = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_percentage
FROM bookings b
GROUP BY EXTRACT(MONTH FROM b.arrival_date)
ORDER BY arrival_month;
-- Find all bookings where total_of_special_requests >= 3, sorted by adr descending — are high-request guests also high-paying guests?
-- Solution:
SELECT
    b.booking_id,
    b.total_of_special_requests,
    b.adr
FROM bookings b
WHERE b.total_of_special_requests >= 3
ORDER BY b.adr DESC;
-- Using CASE WHEN, bucket every booking's lead_time into 'Last minute (0-7 days)', 'Short (8-30)', 'Medium (31-90)', 'Long (90+)', then count bookings and cancellation rate in each bucket.
-- Solution:
SELECT
    CASE 
        WHEN b.lead_time BETWEEN 0 AND 7 THEN 'Last minute (0-7 days)'
        WHEN b.lead_time BETWEEN 8 AND 30 THEN 'Short (8-30 days)'
        WHEN b.lead_time BETWEEN 31 AND 90 THEN 'Medium (31-90 days)'
        ELSE 'Long (90+ days)'
    END AS lead_time_bucket,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN b.is_canceled = TRUE THEN 1 ELSE 0 END) AS canceled_bookings,
    ROUND(SUM(CASE WHEN b.is_canceled = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_percentage
FROM bookings b
GROUP BY CASE 
        WHEN b.lead_time BETWEEN 0 AND 7 THEN 'Last minute (0-7 days)'
        WHEN b.lead_time BETWEEN 8 AND 30 THEN 'Short (8-30 days)'
        WHEN b.lead_time BETWEEN 31 AND 90 THEN 'Medium (31-90 days)'
        ELSE 'Long (90+ days)'
    END;
-- Find the average days_in_waiting_list for bookings that were eventually cancelled vs. bookings that were not — does a longer wait correlate with cancellation?
-- Solution:
SELECT
    CASE 
        WHEN b.is_canceled = TRUE THEN 'Cancelled'
        ELSE 'Not Cancelled'
    END AS cancellation_status,
    ROUND(AVG(b.days_in_waiting_list), 2) AS average_days_in_waiting_list
FROM bookings b
GROUP BY CASE 
        WHEN b.is_canceled = TRUE THEN 'Cancelled'
        ELSE 'Not Cancelled'
    END;
-- Hard --
-- Find every deposit_type = 'Non Refund' booking that was still is_canceled = FALSE — a non-refundable deposit is meant to discourage cancellation, so check whether it's working, and separately check whether any Non Refund bookings were cancelled anyway.
-- Solution:
SELECT
    b.booking_id,
    b.deposit_type,
    b.is_canceled
FROM bookings b
WHERE b.deposit_type = 'Non Refund' AND b.is_canceled = FALSE;
-- For each customer_type, calculate what percentage of bookings had agent IS NOT NULL (i.e., were booked through a travel agent) vs. booked directly — use COUNT(agent) vs COUNT(*) to see how NULL is silently excluded from COUNT(column).
-- Solution:
SELECT
    b.customer_type,
    COUNT(b.agent) AS bookings_with_agent,
    COUNT(*) AS total_bookings,
    ROUND(COUNT(b.agent) * 100.0 / COUNT(*), 2) AS percentage_with_agent
FROM bookings b
GROUP BY b.customer_type;
--Find the reserved_room_type and assigned_room_type combinations where they don't match — count how often each hotel reassigns guests to a different room type than they booked, and whether mismatched rooms have a higher cancellation rate.
-- Solution:
SELECT
    b.hotel_id,
    b.reserved_room_type,
    b.assigned_room_type,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN b.is_canceled = TRUE THEN 1 ELSE 0 END) AS canceled_bookings,
    ROUND(SUM(CASE WHEN b.is_canceled = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_percentage
FROM bookings b
WHERE b.reserved_room_type != b.assigned_room_type
GROUP BY b.hotel_id, b.reserved_room_type, b.assigned_room_type;
--For each country (excluding NULL), calculate the average adr, but only include countries with more than 50 bookings (HAVING) — avoid drawing conclusions from tiny sample sizes.
-- Solution:
SELECT
    b.country,
    ROUND(AVG(b.adr), 2) AS average_adr,
    COUNT(*) AS total_bookings
FROM bookings b
WHERE b.country IS NOT NULL
GROUP BY b.country
HAVING COUNT(*) > 50;
--Find the busiest arrival_date_week_number for each hotel_id by total booking count — use a subquery or window-style approach to identify peak booking weeks per hotel without collapsing to one row per hotel manually.
-- Solution:
SELECT
    b.hotel_id,
    b.arrival_date_week_number,
    COUNT(*) AS total_bookings
FROM bookings b
GROUP BY b.hotel_id, b.arrival_date_week_number
ORDER BY b.hotel_id, total_bookings DESC;
--Calculate the overall no-show rate (reservation_status = 'No-Show') as a percentage of all non-cancelled-in-advance bookings, broken down by hotel_id and customer_type together.
-- Solution:
SELECT
    b.hotel_id,
    b.customer_type,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN b.reservation_status = 'No-Show' THEN 1 ELSE 0 END) AS no_show_bookings,
    ROUND(SUM(CASE WHEN b.reservation_status = 'No-Show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS no_show_rate_percentage
FROM bookings b
WHERE b.is_canceled = FALSE
GROUP BY b.hotel_id, b.customer_type;
--Find bookings where children > 0 or babies > 0, calculate their average total_of_special_requests compared to bookings with no children/babies — do families request more?
-- Solution:
SELECT
    CASE 
        WHEN b.children > 0 OR b.babies > 0 THEN 'Families'
        ELSE 'No Children/Babies'
    END AS family_status,
    ROUND(AVG(b.total_of_special_requests), 2) AS average_special_requests,
    COUNT(*) AS total_bookings
FROM bookings b
GROUP BY CASE 
        WHEN b.children > 0 OR b.babies > 0 THEN 'Families'
        ELSE 'No Children/Babies'
    END;
--Using COALESCE, treat every NULL agent value as 0 (meaning "no agent"), then find the single agent number (real or the 0 placeholder) responsible for the most bookings per hotel_id.
-- Solution:
SELECT
    b.hotel_id,
    COALESCE(b.agent, 0) AS agent,
    COUNT(*) AS total_bookings
FROM bookings b
GROUP BY b.hotel_id, COALESCE(b.agent, 0)
ORDER BY b.hotel_id, total_bookings DESC;
-- Specifically for NULL handling practice

-- Run COUNT(*) vs COUNT(country) vs COUNT(agent) vs COUNT(company) on the whole table side by side — this single query shows you exactly how many rows each column is silently missing, without needing WHERE ... IS NULL at all.
-- Solution:
SELECT
    COUNT(*) AS total_rows,
    COUNT(b.country) AS count_country,
    COUNT(b.agent) AS count_agent,
    COUNT(b.company) AS count_company
FROM bookings b;
-- Find all bookings where company IS NOT NULL — since company is missing in over 95% of rows, these are the rare corporate-booked stays. Compare their average adr and lead_time against the rest of the table.
-- Solution:
SELECT
    b.hotel_id,
    b.company,
    ROUND(AVG(b.adr), 2) AS average_adr,
    ROUND(AVG(b.lead_time), 2) AS average_lead_time
FROM bookings b
WHERE b.company IS NOT NULL
GROUP BY b.hotel_id, b.company;
-- Rewrite question 9 above using COALESCE(agent, -1) instead of relying on COUNT() behavior, and confirm you get the same grouping result both ways — a good check that you understand why both approaches agree here.
-- Solution:
SELECT
    b.hotel_id,
    COALESCE(b.agent, -1) AS agent,
    COUNT(*) AS total_bookings
FROM bookings b
GROUP BY b.hotel_id, COALESCE(b.agent, -1)
ORDER BY b.hotel_id, total_bookings DESC;