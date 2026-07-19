-- Source: Kaggle - Medical Appointment Scheduling System
-- (patients.csv, slots.csv, appointments.csv)

DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS slots;
DROP TABLE IF EXISTS patients;

-- 1. Patients Table
CREATE TABLE patients (
    patient_id      INT PRIMARY KEY,
    name            VARCHAR(50) NOT NULL,
    sex             VARCHAR(10) NOT NULL CHECK (sex IN ('Male', 'Female')),
    dob             DATE NOT NULL,
    insurance       VARCHAR(50) NOT NULL
);

-- 2. Slots Table (clinic's bookable appointment slots)
CREATE TABLE slots (
    slot_id             INT PRIMARY KEY,
    appointment_date    DATE NOT NULL,
    appointment_time    TIME NOT NULL,
    is_available        BOOLEAN NOT NULL DEFAULT TRUE
);

-- 3. Appointments Table (transactional table linking patients to slots)
CREATE TABLE appointments (
    appointment_id          INT PRIMARY KEY,
    slot_id                 INT NOT NULL REFERENCES slots(slot_id) ON DELETE CASCADE,
    scheduling_date         DATE NOT NULL,      -- date the appointment was booked
    appointment_date        DATE NOT NULL,      -- date the appointment is scheduled for
    appointment_time        TIME NOT NULL,
    scheduling_interval     INT NOT NULL,       -- days between booking and appointment
    status                  VARCHAR(20) NOT NULL CHECK (
                                status IN ('attended', 'cancelled', 'did not attend', 'unknown', 'scheduled')
                             ),
    check_in_time           TIME,               -- NULL if patient never checked in
    appointment_duration    DECIMAL(5,2),        -- minutes, NULL if not attended
    start_time              TIME,
    end_time                TIME,
    waiting_time            DECIMAL(5,2),        -- minutes, NULL if not attended
    patient_id              INT NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    sex                     VARCHAR(10) NOT NULL CHECK (sex IN ('Male', 'Female')),
    age                     INT NOT NULL CHECK (age >= 0),
    age_group               VARCHAR(10) NOT NULL
);

-- Performance indexes for common analytical queries
CREATE INDEX idx_appointments_patient   ON appointments(patient_id);
CREATE INDEX idx_appointments_slot      ON appointments(slot_id);
CREATE INDEX idx_appointments_status    ON appointments(status);
CREATE INDEX idx_appointments_date      ON appointments(appointment_date);
CREATE INDEX idx_slots_date             ON slots(appointment_date);