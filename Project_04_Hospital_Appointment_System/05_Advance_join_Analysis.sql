-- A few join techniques.

-- Self-join — joining a table to itself, using two aliases (e.g. appointments a1, appointments a2). Used when you need to compare rows within the same table — like a patient's two different appointments against each other.

-- Anti-join — finding rows in one table that have no match in another. Two ways to write it: LEFT JOIN ... WHERE right_table.id IS NULL, or WHERE NOT EXISTS (SELECT 1 FROM ... WHERE ...). Both answer "find X that never had a Y."

-- Multi-table join with aggregation — joining 3 tables, then GROUP BY on a column from one of the joined tables (not just the base table) to produce a summary report.

-- Join patients + appointments + slots (all three) to produce one row per appointment showing patient name, insurance, appointment status, and the slot's is_available flag.
-- Solution:
SELECT p.name, p.insurance, a.status, s.is_available
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN slots s ON a.slot_id = s.slot_id;
-- Using a self-join on appointments, find pairs of appointments belonging to the same patient where one appointment's status = 'attended' and a later appointment's status = 'did not attend' — patients whose reliability got worse over time.
-- Solution:
SELECT p.name, a1.patient_id, a1.appointment_id AS attended_appointment_id, a2.appointment_id AS did_not_attend_appointment_id
FROM patients p
JOIN appointments a1 ON p.patient_id = a1.patient_id
JOIN appointments a2 ON a1.patient_id = a2.patient_id
WHERE a1.status = 'attended' AND a2.status = 'did not attend' AND a2.appointment_date > a1.appointment_date;
-- Using a self-join, find every patient who has two or more appointments on the same appointment_date (a possible double-booking or data issue).
-- Solution:
SELECT p.name, a1.patient_id, a1.appointment_date, a1.appointment_id AS appointment_1, a2.appointment_id AS appointment_2
FROM patients p
JOIN appointments a1 ON p.patient_id = a1.patient_id
JOIN appointments a2 ON a1.patient_id = a2.patient_id
WHERE a1.appointment_date = a2.appointment_date AND a1.appointment_id != a2.appointment_id;
-- Using an anti-join (LEFT JOIN ... IS NULL or NOT EXISTS), find every slot_id in slots that was never used in appointments.
-- Solution:
SELECT s.slot_id
FROM slots s
LEFT JOIN appointments a ON s.slot_id = a.slot_id
WHERE a.slot_id IS NULL;
-- Using an anti-join, find every patient in patients who has never had an appointment with status = 'attended' — i.e., every visit they've ever booked was cancelled, no-show, or unknown.
-- Solution:
SELECT p.patient_id, p.name
FROM patients p
WHERE NOT EXISTS (
    SELECT 1
    FROM appointments a
    WHERE p.patient_id = a.patient_id AND a.status = 'attended'
);
-- Join patients + appointments, group by insurance, and show the average waiting_time and total appointment count per insurance provider — only for providers with more than 20 appointments (HAVING).
-- Solution:
SELECT p.insurance, AVG(a.waiting_time)::numeric(10,2) || ' Minutes' AS avg_waiting_time, COUNT(*) AS total_appointments
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.insurance
HAVING COUNT(*) > 20;
-- Join appointments + slots and find every appointment where the join condition partially fails — meaning appointments.slot_id matches a real slots.slot_id, but the appointment_date/appointment_time values between the two tables don't agree (a consistency-check join, not just an equality join).
-- Solution:
SELECT a.appointment_id, a.slot_id, a.appointment_date, a.appointment_time, s.slot_id AS slot_slot_id, s.appointment_date, s.appointment_time
FROM appointments a
JOIN slots s ON a.slot_id = s.slot_id
WHERE a.appointment_date != s.appointment_date OR a.appointment_time != s.appointment_time;
-- Using a self-join on appointments (joined on patient_id, excluding matching the same appointment to itself), find the average number of days between a patient's consecutive appointments — you'll need scheduling_date or appointment_date subtraction.
-- Solution:
SELECT a1.patient_id, AVG(a2.appointment_date - a1.appointment_date)::numeric(10,2) || ' Days' AS avg_days_between_appointments
FROM appointments a1
JOIN appointments a2 ON a1.patient_id = a2.patient_id AND a1.appointment_date < a2.appointment_date
GROUP BY a1.patient_id;
-- Join patients + appointments, group by age_group and sex together, and use a CASE WHEN inside an aggregate (SUM(CASE WHEN status = 'did not attend' THEN 1 ELSE 0 END)) to build a no-show count per demographic — all in one multi-table joined, grouped query.
-- Solution:
SELECT a.age_group, p.sex,
       COUNT(*) AS total_appointments,
       SUM(CASE WHEN a.status = 'did not attend' THEN 1 ELSE 0 END) AS no_show_count,
       (SUM(CASE WHEN a.status = 'did not attend' THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::numeric(10,2) || ' %' AS no_show_rate
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY a.age_group, p.sex;
-- Join all three tables (patients, appointments, slots), then use an anti-join to find every patient_id that appears in patients but has zero rows at all in appointments — patients registered in the system who never booked anything.
-- Solution:
SELECT p.patient_id, p.name
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
WHERE a.patient_id IS NULL;