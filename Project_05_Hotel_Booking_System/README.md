# Project 5: Hotel Booking System

A SQL project built around a real-world hotel booking dataset, focused on normalizing a flat file into a proper relational schema and practicing analysis ranging from basic aggregation through window functions and CTEs.

## Overview

This project works with booking records from two hotels — a city hotel and a resort hotel. Unlike Project 4, the source data doesn't come pre-split into related tables; it's a single wide file covering booking details, guest composition, cancellation status, pricing, and how each booking was made. Designing a sensible schema from that flat structure was part of the exercise itself, not just loading data that was already normalized.

## Dataset

Source: Kaggle — Hotel Booking Demand (`jessemostipak/hotel-booking-demand`).

The original file, `hotel_bookings.csv`, contains 119,390 rows covering bookings from 2015-2017 across both hotels, with no booking ID, guest ID, or separate lookup tables — just one row per booking.

For this project, a stratified sample of 4,500 rows was pulled, proportional by hotel and cancellation status, so the real cancellation rate (~37%) and the split between the two hotels are both preserved in the sample.

## Schema

**hotels**
`hotel_id` (PK), `hotel_name`

A small lookup table — the source data only ever distinguishes "City Hotel" and "Resort Hotel," so this stays intentionally simple rather than being over-normalized.

**bookings**
`booking_id` (PK, surrogate — not present in the source data), `hotel_id` (FK → hotels), `is_canceled`, `lead_time`, `arrival_date`, `arrival_date_week_number`, `stays_in_weekend_nights`, `stays_in_week_nights`, `adults`, `children`, `babies`, `meal`, `country`, `market_segment`, `distribution_channel`, `is_repeated_guest`, `previous_cancellations`, `previous_bookings_not_canceled`, `reserved_room_type`, `assigned_room_type`, `booking_changes`, `deposit_type`, `agent`, `company`, `days_in_waiting_list`, `customer_type`, `adr`, `required_car_parking_spaces`, `total_of_special_requests`, `reservation_status`, `reservation_status_date`

`arrival_date` is a real `DATE` column, built by combining the source file's separate year, month name, and day fields — this makes date-based analysis far more natural than working with three disconnected columns.

`agent` and `company` are kept as plain nullable integers rather than split into their own lookup tables. The source data gives no descriptive information about them beyond an ID number, so a separate table would add structure without adding analytical value.

## NULLs Are Meaningful, Not Missing Data

`children`, `country`, `agent`, and `company` all contain real NULLs carried over from the source file — none of them were artificially introduced or cleaned away.

`agent` and `company` in particular are the most important to understand correctly: a `NULL` here usually means the booking was made directly by the guest rather than through a travel agent or corporate account, not that data is missing or broken. Treating these as "dirty data" and filling them in would erase a real signal about how each booking was made.

## Files

`01_schema.sql` =>> Table definitions, constraints, foreign keys, and indexes 
`02_inserts.sql`=>>  Sample data (4,500 rows) with real NULLs preserved 
`basic_analysis.sql` =>>  Single-table filtering, aggregation, CASE logic, and NULL handling 
`advance_analysis.sql` =>> Window functions, CTEs, running totals, and top-N-per-group analysis

## Concepts Practiced

- Designing a normalized schema from a single flat source file
- NULL handling where NULL carries real business meaning (not just missing data)
- `GROUP BY` / `HAVING` with multi-column grouping
- `CASE`-based bucketing and classification
- Window functions: `RANK()`, `ROW_NUMBER()`, `NTILE()`, `LAG()`, running/moving aggregates
- CTEs used as intermediate aggregation steps for further analysis
- Top-N-per-group analysis
- Revenue and cancellation-rate calculations across multiple dimensions

## How to Run

1. Run `01_schema.sql` to create the tables.
2. Run `02_inserts.sql` to load the sample data.
3. Run the queries in order.

Built in PostgreSQL (via VS Code / pgAdmin).