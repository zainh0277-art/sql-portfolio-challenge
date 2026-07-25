-- Find the cancellation rate (as a percentage) for each hotel, joining bookings to hotels to show the hotel name instead of hotel_id.

--For each market_segment, calculate the average adr (average daily rate) and the total number of bookings — sorted by average adr descending.

-- Find the month with the highest number of arrivals using arrival_date (extract month from the date, don't rely on a separate month column). Calculate the average length of stay (stays_in_weekend_nights + stays_in_week_nights) for each customer_type, rounded to 1 decimal place.

-- Find the top 10 country values by total number of bookings — then find the top 10 by average adr instead, and compare whether it's the same countries.

-- For each deposit_type, calculate the cancellation rate — which deposit type has the highest proportion of cancellations, and does that surprise you given what "Non Refund" implies?

-- Using a CASE statement, bucket lead_time into ranges ('0-7 days', '8-30 days', '31-90 days', '90+ days'), then find the cancellation rate for each bucket — does booking further in advance correlate with higher cancellation?

-- Find all bookings where assigned_room_type does not match reserved_room_type — calculate what percentage of total bookings this represents, and check whether mismatched-room bookings have a different average total_of_special_requests than matched ones.

-- Calculate total expected revenue (adr * (stays_in_weekend_nights + stays_in_week_nights)) for only non-cancelled bookings, grouped by hotel.
-- Find the average days_in_waiting_list for bookings that were eventually cancelled vs. bookings that were not — is there a meaningful difference?
-- For repeated guests (is_repeated_guest = TRUE), compare their cancellation rate against first-time guests — do repeat guests cancel less often?
-- Find the busiest arrival_date_week_number for each hotel separately (highest count of bookings) — this needs a GROUP BY on two columns together.
-- Calculate what percentage of bookings include at least one child or baby (children > 0 OR babies > 0), then compare the average total_of_special_requests for bookings with kids vs. without.
-- Using CASE, classify each booking as 'Weekend-heavy', 'Weekday-heavy', or 'Balanced' based on comparing stays_in_weekend_nights to stays_in_week_nights — then count how many bookings fall into each category per hotel.
-- Find the distribution_channel with the highest average adr, but only include channels with at least 50 bookings (HAVING) — a channel with 3 bookings and a high average isn't a reliable signal.

-- NULL Handling Questions --

-- Count how many bookings have a NULL value in agent, and calculate what percentage of total bookings that represents — what does a NULL agent most likely mean here (booked directly, not through a travel agent)?

-- Use COALESCE to replace NULL values in country with 'Unknown', then re-run your top-10-countries-by-bookings query from question 5 — where does 'Unknown' rank?

-- Compare the average adr for bookings where company IS NULL vs. company IS NOT NULL — do company-booked stays tend to be cheaper or more expensive per night?
-- Use COALESCE(children, 0) to safely calculate total guests (adults + COALESCE(children,0) + babies) for every booking — then explain in a comment why leaving out the COALESCE would silently produce wrong totals for a small number of rows.
-- Find all bookings where both agent IS NULL and company IS NULL — what does a booking with neither of these usually represent (a walk-in or direct personal booking), and what's the cancellation rate for this group compared to the overall average?