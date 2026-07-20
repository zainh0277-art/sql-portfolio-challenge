-- 1:List all patients whose sex = 'Female', sorted alphabetically by name.
-- Solution:
SELECT * FROM patients WHERE sex = 'Female' ORDER BY name;
-- 2:Find all patients covered by "BioCrest Harmony" insurance.
-- Solution:
    SELECT * FROM patients WHERE insurance = 'BioCrest Harmony';
-- 3:Count how many patients are registered under each insurance provider, ordered from highest to lowest.
-- Solution:
SELECT insurance, COUNT(*) AS patient_count FROM patients GROUP BY insurance ORDER BY patient_count DESC;
-- 4:Find the 10 oldest patients by dob (earliest birth date first).
-- Solution:
SELECT * FROM patients ORDER BY dob ASC LIMIT 10;
-- 5:List all appointments with status = 'did not attend', ordered by appointment_date (most recent first).
-- Solution:
SELECT * FROM appointments WHERE status = 'did not attend' ORDER BY appointment_date DESC;
-- 6:Count the total number of appointments for each status value.
-- Solution:
SELECT status, COUNT(*) AS appointment_count FROM appointments GROUP BY status;
-- 7:Find all appointments where age > 65, sorted by age descending.
-- Solution:
SELECT * FROM appointments WHERE age > 65 ORDER BY age DESC;
-- 8:Count how many appointments fall into each age_group, ordered from highest count to lowest.
-- Solution:
SELECT age_group, COUNT(*) AS appointment_count FROM appointments GROUP BY age_group ORDER BY appointment_count DESC;
-- 9:Find the average waiting_time across all appointments (think about whether NULL rows affect this result).
-- Solution:
SELECT ROUND(AVG(waiting_time), 2) || ' Minutes' AS average_waiting_time FROM appointments;
-- 10:Find all appointments where check_in_time IS NULL — what does this tell you about those appointments?
-- Solution:
SELECT * FROM appointments WHERE check_in_time IS NULL;
-- 11:Find the appointment(s) with the longest appointment_duration.
-- Solution:
SELECT * FROM appointments WHERE appointment_duration = (SELECT MAX(appointment_duration) FROM appointments);
-- 12:List all appointments scheduled on a weekend (use a date function on appointment_date).
-- Solution:
SELECT * FROM appointments WHERE EXTRACT(DOW FROM appointment_date) IN (5, 6);
-- 13:Find all slots where is_available = TRUE, grouped by appointment_date, showing the count of free slots per day.
-- Solution:
SELECT appointment_date, COUNT(*) AS free_slots FROM slots WHERE is_available = TRUE GROUP BY appointment_date;
-- 14:Find the earliest and latest appointment_date in the slots table (the full date range your dataset covers).
-- Solution:
SELECT MIN(appointment_date) AS earliest_appointment, MAX(appointment_date) AS latest_appointment FROM slots;
-- 15:Find all appointments where scheduling_interval > 30 (patients who booked more than a month in advance), sorted by scheduling_interval descending.
-- Solution:
SELECT * FROM appointments WHERE scheduling_interval > 30 ORDER BY scheduling_interval DESC;