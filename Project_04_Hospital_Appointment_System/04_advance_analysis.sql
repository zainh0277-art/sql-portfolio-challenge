-- Mix of GROUP BY/HAVING, correlated subqueries, UNION/UNION ALL, and one FULL OUTER JOIN data-integrity check — all against your patients, slots, appointments tables.

-- GROUP BY / HAVING

-- For each status, show the count of appointments and what percentage that is of the total appointment count (you'll need a subquery or a second query for the grand total).
-- Solution:
SELECT status, COUNT(*) as appointment_count, 
       (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM appointments))::numeric(10,2) || ' %' as percentage_of_total
FROM appointments
GROUP BY status;
-- For each age_group, show the count of appointments — but only include age groups with more than 30 appointments (HAVING).
-- Solution:
SELECT age_group, COUNT(*) as appointment_count
FROM appointments
GROUP BY age_group
HAVING COUNT(*) > 30;
-- Find every age_group whose average scheduling_interval is higher than the overall average scheduling_interval across all appointments (GROUP BY + HAVING with a subquery for the overall average).
-- Solution:
SELECT age_group, AVG(scheduling_interval)::numeric(10,2) as avg_scheduling_interval
FROM appointments
GROUP BY age_group
HAVING AVG(scheduling_interval) > (SELECT AVG(scheduling_interval) FROM appointments);
-- For each combination of sex and age_group, show the count of appointments and the average waiting_time, but only for groups where the average waiting_time exceeds 15 minutes.
-- Solution:
SELECT sex, age_group, COUNT(*) as appointment_count, AVG(waiting_time)::numeric(10,2) || ' Minutes' as avg_waiting_time
FROM appointments
GROUP BY sex, age_group
HAVING AVG(waiting_time) > 15;

-- Correlated subqueries

-- List every appointment's appointment_id, age_group, and waiting_time, along with the average waiting_time of that appointment's own age_group shown as an extra column (don't collapse the rows — one row per appointment, but show the average waiting_time for that age_group in a separate column).
-- Solution:
SELECT a.appointment_id, a.age_group, a.waiting_time,
       (SELECT AVG(waiting_time) FROM appointments WHERE age_group = a.age_group)::numeric(10,2) as avg_waiting_time_for_age_group
FROM appointments a;
-- Find all appointments where waiting_time is above the average waiting_time for that appointment's status.
-- Solution:
SELECT a.appointment_id, a.status, a.waiting_time
FROM appointments a
WHERE a.waiting_time > (SELECT AVG(waiting_time) FROM appointments WHERE status = a.status);
-- For each age_group, find the single appointment with the maximum waiting_time — show appointment_id, age_group, and waiting_time.
-- Solution:
SELECT a.appointment_id, a.age_group, a.waiting_time
FROM appointments a
WHERE a.waiting_time = (SELECT MAX(waiting_time) FROM appointments WHERE age_group = a.age_group);
-- For each age_group, find the single appointment with the minimum scheduling_interval (the patient who booked closest to their appointment date within that age group).
-- Solution:
SELECT a.appointment_id, a.age_group, a.scheduling_interval
FROM appointments a
WHERE a.scheduling_interval = (SELECT MIN(scheduling_interval) FROM appointments WHERE age_group = a.age_group);
-- Find every patient whose most recent appointment (MAX(appointment_date) for that patient_id) has a status of 'cancelled' — a correlated subquery to identify "last appointment" per patient.
-- Solution:
SELECT p.patient_id, p.name, a.appointment_date, a.status
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
WHERE a.appointment_date = (SELECT MAX(appointment_date) FROM appointments WHERE patient_id = p.patient_id)
AND a.status = 'cancelled';

-- UNION / UNION ALL

-- Build a combined "risk list": patients who booked more than 60 days in advance (scheduling_interval > 60) UNION patients whose appointment status = 'did not attend'.
-- Solution:
SELECT patient_id, 'high risk' as risk_category
FROM appointments
WHERE scheduling_interval > 60
UNION
SELECT patient_id, 'high risk' as risk_category
FROM appointments
WHERE status = 'did not attend';
-- Same idea as #10, but this time use UNION ALL instead of UNION, and explain in a comment why the row count differs between the two versions.
-- Solution:
SELECT patient_id, 'high risk' as risk_category
FROM appointments
WHERE scheduling_interval > 60
UNION ALL
SELECT patient_id, 'high risk' as risk_category
FROM appointments
WHERE status = 'did not attend';
-- The row count differs between UNION and UNION ALL because UNION removes duplicate rows from the combined result set, while UNION ALL includes all rows, even duplicates. If a patient meets both criteria (scheduling_interval > 60 and status = 'did not attend'), they will appear only once in the UNION result but twice in the UNION ALL result.

-- A little more advanced / mixed

-- Using FULL OUTER JOIN between slots and appointments on slot_id, find (a) slots that were never booked into an appointment, and (b) any appointment slot_id values with no matching row in slots — a data-integrity check for your FK relationship.
-- Solution:
SELECT s.slot_id, a.appointment_id
FROM slots s
FULL OUTER JOIN appointments a ON s.slot_id = a.slot_id
WHERE s.slot_id IS NULL OR a.appointment_id IS NULL;
-- Find every insurance provider (join patients → appointments) whose no-show rate (did not attend + cancelled as a % of their total appointments) is higher than the overall no-show rate across the whole dataset — combine GROUP BY/HAVING with a subquery for the overall benchmark.
-- Solution:
SELECT p.insurance,
       COUNT(*) as total_appointments,
       SUM(CASE WHEN a.status IN ('did not attend', 'cancelled') THEN 1 ELSE 0 END) as no_show_count,
       (SUM(CASE WHEN a.status IN ('did not attend', 'cancelled') THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::numeric(10,2) || ' %' as no_show_rate
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.insurance
HAVING (SUM(CASE WHEN a.status IN ('did not attend', 'cancelled') THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::numeric(10,2) > (
    SELECT (SUM(CASE WHEN status IN ('did not attend', 'cancelled') THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::numeric(10,2)
    FROM appointments
);
-- For each patient_id who has more than one appointment, show their name, appointment count, and their average waiting_time compared to the average waiting_time of all patients — using a correlated subquery for the individual average and a plain subquery for the overall benchmark, side by side in one row per patient.
-- Solution:
SELECT p.patient_id, p.name, COUNT(a.appointment_id) as appointment_count,
       AVG(a.waiting_time)::numeric(10,2) as avg_waiting_time,
       (SELECT AVG(waiting_time) FROM appointments)::numeric(10,2) as overall_avg_waiting_time
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
WHERE p.patient_id IN (
    SELECT patient_id
    FROM appointments
    GROUP BY patient_id
    HAVING COUNT(*) > 1
)
GROUP BY p.patient_id, p.name;
-- Analysis Completed