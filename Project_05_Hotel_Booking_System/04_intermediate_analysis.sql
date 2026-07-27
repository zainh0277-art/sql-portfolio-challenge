-- Find the cancellation rate (as a percentage) for each hotel, joining bookings to hotels to show the hotel name instead of hotel_id.
-- Solution:
SELECT
    
    h.hotel_name,
    ROUND(COUNT(CASE WHEN b.is_canceled = TRUE THEN 1 END) * 100.0 / COUNT(*),2) || '%' AS cancellation_rate_percentage
FROM bookings b
JOIN hotels h ON b.hotel_id = h.hotel_id
GROUP BY h.hotel_name;
--For each market_segment, calculate the average adr (average daily rate) and the total number of bookings — sorted by average adr descending.
-- Solution:
SELECT
    market_segment,
    ROUND(AVG(adr), 2) AS average_adr,
    COUNT(*) AS total_bookings
FROM bookings
GROUP BY market_segment
ORDER BY average_adr DESC;
-- Find the month with the highest number of arrivals using arrival_date (extract month from the date, don't rely on a separate month column). Calculate the average length of stay (stays_in_weekend_nights + stays_in_week_nights) for each customer_type, rounded to 1 decimal place.
-- Solution:
SELECT
    EXTRACT(MONTH FROM arrival_date) AS arrival_month,
    COUNT(*) AS total_arrivals,
    ROUND(AVG(stays_in_weekend_nights + stays_in_week_nights), 1) AS average_length_of_stay
FROM bookings
GROUP BY EXTRACT(MONTH FROM arrival_date)
ORDER BY total_arrivals DESC
LIMIT 1;
-- Find the top 10 country values by total number of bookings — then find the top 10 by average adr instead, and compare whether it's the same countries.
-- Solution:
SELECT
    country,
    COUNT(*) AS total_bookings,
    ROUND(AVG(adr),2) AS average_adr
FROM bookings
GROUP BY country
ORDER BY total_bookings DESC
LIMIT 10;
-- For each deposit_type, calculate the cancellation rate — which deposit type has the highest proportion of cancellations, and does that surprise you given what "Non Refund" implies?
-- Solution:
SELECT
    deposit_type,
    ROUND(COUNT(CASE WHEN is_canceled = TRUE THEN 1 END) * 100.0 / COUNT(*),2) || '%' AS cancellation_rate_percentage
FROM bookings
GROUP BY deposit_type;
-- Using a CASE statement, bucket lead_time into ranges ('0-7 days', '8-30 days', '31-90 days', '90+ days'), then find the cancellation rate for each bucket — does booking further in advance correlate with higher cancellation?
-- Solution:
SELECT
    CASE
        WHEN lead_time BETWEEN 0 AND 7 THEN '0-7 days'
        WHEN lead_time BETWEEN 8 AND 30 THEN '8-30 days'
        WHEN lead_time BETWEEN 31 AND 90 THEN '31-90 days'
        ELSE '90+ days'
    END AS lead_time_bucket,
    ROUND(COUNT(CASE WHEN is_canceled = TRUE THEN 1 END) * 100.0 / COUNT(*),2) || '%' AS cancellation_rate_percentage
FROM bookings
GROUP BY lead_time_bucket;
-- Find all bookings where assigned_room_type does not match reserved_room_type — calculate what percentage of total bookings this represents, and check whether mismatched-room bookings have a different average total_of_special_requests than matched ones.
-- Solution:
SELECT
    COUNT(*) AS mismatched_bookings,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bookings), 2) || '%' AS percentage_of_total_bookings,
    ROUND(AVG(CASE WHEN assigned_room_type != reserved_room_type THEN total_of_special_requests END), 2) AS avg_special_requests_mismatched,
    ROUND(AVG(CASE WHEN assigned_room_type = reserved_room_type THEN total_of_special_requests END), 2) AS avg_special_requests_matched
FROM bookings
WHERE assigned_room_type != reserved_room_type;
-- Calculate total expected revenue (adr * (stays_in_weekend_nights + stays_in_week_nights)) for only non-cancelled bookings, grouped by hotel.
-- Solution:
SELECT
    h.hotel_name,
    ROUND(SUM(adr * (stays_in_weekend_nights + stays_in_week_nights)), 2) AS total_expected_revenue
FROM bookings b
JOIN hotels h ON b.hotel_id = h.hotel_id
WHERE b.is_canceled = FALSE
GROUP BY h.hotel_name;
-- Find the average days_in_waiting_list for bookings that were eventually cancelled vs. bookings that were not — is there a meaningful difference?
-- Solution:
SELECT
    is_canceled,
    ROUND(AVG(days_in_waiting_list), 2) AS average_days_in_waiting_list
FROM bookings
GROUP BY is_canceled;
-- For repeated guests (is_repeated_guest = TRUE), compare their cancellation rate against first-time guests — do repeat guests cancel less often?
-- Solution:
SELECT
    is_repeated_guest,
    ROUND(COUNT(CASE WHEN is_canceled = TRUE THEN 1 END) * 100.0 / COUNT(*),2) || '%' AS cancellation_rate_percentage
FROM bookings
GROUP BY is_repeated_guest;
-- Find the busiest arrival_date_week_number for each hotel separately (highest count of bookings) — this needs a GROUP BY on two columns together.
-- Solution:
SELECT
    h.hotel_name,
    arrival_date_week_number,
    COUNT(*) AS total_bookings
FROM bookings b
JOIN hotels h ON b.hotel_id = h.hotel_id
GROUP BY h.hotel_name, arrival_date_week_number
ORDER BY total_bookings DESC
LIMIT 1;
-- Calculate what percentage of bookings include at least one child or baby (children > 0 OR babies > 0), then compare the average total_of_special_requests for bookings with kids vs. without.
-- Solution:
SELECT
    ROUND(COUNT(CASE WHEN children > 0 OR babies > 0 THEN 1 END) * 100.0 / COUNT(*), 2) || '%' AS percentage_with_kids,
    ROUND(AVG(CASE WHEN children > 0 OR babies > 0 THEN total_of_special_requests END), 2) AS avg_special_requests_with_kids,
    ROUND(AVG(CASE WHEN children = 0 AND babies = 0 THEN total_of_special_requests END), 2) AS avg_special_requests_without_kids
FROM bookings
GROUP BY children, babies;
-- Using CASE, classify each booking as 'Weekend-heavy', 'Weekday-heavy', or 'Balanced' based on comparing stays_in_weekend_nights to stays_in_week_nights — then count how many bookings fall into each category per hotel.
-- Solution:
SELECT
    h.hotel_name,
    CASE
        WHEN stays_in_weekend_nights > stays_in_week_nights THEN 'Weekend-heavy'
        WHEN stays_in_weekend_nights < stays_in_week_nights THEN 'Weekday-heavy'
        ELSE 'Balanced'
    END AS stay_type,
    COUNT(*) AS total_bookings
FROM bookings b
JOIN hotels h ON b.hotel_id = h.hotel_id
GROUP BY h.hotel_name, stay_type;
-- Find the distribution_channel with the highest average adr, but only include channels with at least 50 bookings (HAVING) — a channel with 3 bookings and a high average isn't a reliable signal.
-- Solution:
SELECT
    distribution_channel,
    ROUND(AVG(adr), 2) AS average_adr,
    COUNT(*) AS total_bookings
FROM bookings
GROUP BY distribution_channel
HAVING COUNT(*) >= 50
ORDER BY average_adr DESC;
-- NULL Handling Questions --

-- Count how many bookings have a NULL value in agent, and calculate what percentage of total bookings that represents — what does a NULL agent most likely mean here (booked directly, not through a travel agent)?
-- Solution:
SELECT
    COUNT(*) AS null_agent_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bookings), 2) || '%' AS percentage_of_total_bookings
FROM bookings
WHERE agent IS NULL;
-- Use COALESCE to replace NULL values in country with 'Unknown', then re-run your top-10-countries-by-bookings query from question 5 — where does 'Unknown' rank?
-- Solution:
SELECT
    COALESCE(country, 'Unknown') AS country,
    COUNT(*) AS total_bookings,
    ROUND(AVG(adr),2) AS average_adr
FROM bookings
GROUP BY COALESCE(country, 'Unknown')
ORDER BY total_bookings DESC;
-- Compare the average adr for bookings where company IS NULL vs. company IS NOT NULL — do company-booked stays tend to be cheaper or more expensive per night?
-- Solution:
SELECT
    CASE
        WHEN company IS NULL THEN 'No Company'
        ELSE 'With Company'
    END AS company_status,
    ROUND(AVG(adr), 2) AS average_adr
FROM bookings
GROUP BY company_status;
-- Use COALESCE(children, 0) to safely calculate total guests (adults + COALESCE(children,0) + babies) for every booking — then explain in a comment why leaving out the COALESCE would silently produce wrong totals for a small number of rows.
-- Solution:
SELECT
    adults + COALESCE(children, 0) + babies AS total_guests
FROM bookings;
-- If we didn't use COALESCE, any NULL values in the children column would cause the entire expression to evaluate to NULL, leading to incorrect total guest counts.
-- Find all bookings where both agent IS NULL and company IS NULL — what does a booking with neither of these usually represent (a walk-in or direct personal booking), and what's the cancellation rate for this group compared to the overall average?
-- Solution:
SELECT
    COUNT(*) AS null_agent_company_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bookings), 2) || '%' AS percentage_of_total_bookings,
    ROUND(COUNT(CASE WHEN is_canceled = TRUE THEN 1 END) * 100.0 / COUNT(*), 2) || '%' AS cancellation_rate_percentage
FROM bookings
WHERE agent IS NULL AND company IS NULL;