# Project 4: Hospital Appointment Management System

A SQL project built around a real-world medical appointment scheduling dataset, focused on data quality, NULL handling, and analytical queries around patient attendance and scheduling behavior.

## Overview

This project models a clinic's appointment system: patients register once, slots represent bookable time windows, and appointments link a patient to a slot with a status (attended, cancelled, did not attend, unknown, or scheduled). The dataset is real, not synthetic, which means it comes with genuine data quality issues — missing values that reflect actual gaps in the data rather than randomly injected NULLs.

## Dataset

Source: Kaggle — Medical Appointment Scheduling System dataset.

The original dataset contains three files:

- `patients.csv` — 36,697 rows
- `slots.csv` — 104,360 rows
- `appointments.csv` — 111,488 rows

For this project, a stratified sample of ~4,500 rows was pulled across the three tables (proportional by appointment status, so the real-world mix of attended/cancelled/no-show/etc. is preserved) rather than loading the full dataset. This keeps the data large enough for meaningful aggregate analysis while staying light enough to load and query quickly.

## Schema

-- patients
`patient_id` (PK), `name`, `sex`, `dob`, `insurance`

-- slots
`slot_id` (PK), `appointment_date`, `appointment_time`, `is_available`

-- appointments
`appointment_id` (PK), `slot_id` (FK → slots), `patient_id` (FK → patients), `scheduling_date`, `appointment_date`, `appointment_time`, `scheduling_interval`, `status`, `check_in_time`, `appointment_duration`, `start_time`, `end_time`, `waiting_time`, `sex`, `age`, `age_group`

`appointments` is the central transactional table. `check_in_time`, `appointment_duration`, `start_time`, `end_time`, and `waiting_time` are genuinely NULL whenever a patient did not actually attend — there's nothing to log for a cancelled or no-show visit. This is expected behavior in the data, not something to clean away.

## Concepts Practiced

- Primary key / foreign key design across three related tables
- NULL handling on genuinely incomplete real-world data (not synthetic gaps)
- Aggregation with `GROUP BY` and `HAVING`
- Correlated subqueries (per-group comparisons without collapsing rows)
- `UNION` vs `UNION ALL` and when duplicates should or shouldn't be removed
- Self-joins (comparing a patient's own appointments against each other)
- Anti-joins (`LEFT JOIN ... IS NULL`, `NOT EXISTS`) for finding unmatched or missing records
- `FULL OUTER JOIN` for data integrity checks between `slots` and `appointments`

## How to Run

1. Run `01_schema.sql` to create the tables.
2. Run `02_inserts.sql` to load the sample data.
3. Run the query files in order to work through the analysis.

Built in PostgreSQL (via VS Code / pgAdmin).