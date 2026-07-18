-- 1. Departmental Spend Audit
-- Business Case: The finance director wants a comprehensive breakdown of company spending. Generate a report that displays every department name along with the cumulative total of base pay, overtime pay, and benefits paid out to its employees across all recorded years.
-- Solution:
SELECT
    d.department_name,
    SUM(p.base_pay) AS total_base_pay,
    SUM(p.overtime_pay) AS total_overtime_pay,
    SUM(p.benefits) AS total_benefits
FROM
    departments d
LEFT JOIN
    employees e ON d.department_id = e.department_id
LEFT JOIN
    payroll_ledger p ON e.employee_id = p.employee_id
GROUP BY
    d.department_name;
-- 2. The Empty Departments Check
-- Business Case: HR is conducting system maintenance and wants to clean up unused entries. Provide a list of all department names that currently have absolutely no employees assigned to them.
-- Solution:
SELECT
    d.department_name
FROM
    departments d
LEFT JOIN
    employees e ON d.department_id = e.department_id
WHERE
    e.employee_id IS NULL;
-- 3. The Onboarding Payroll Gap
-- Business Case: Internal audit suspects some newer or transferred staff are missing from the financial systems. Find all active employees who are registered in the system but have never received a single payout record in the payroll ledger.
-- Solution:
SELECT
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN payroll_ledger p ON e.employee_id = p.employee_id
WHERE p.employee_id IS NULL;
-- 4. Full Department Headcount Snapshot
-- Business Case: Leadership needs a master headcount sheet for corporate budgeting. List every single department name in the database along with the total count of active employees currently assigned to it. Departments with zero active employees must still appear in the results with a headcount of 0.
-- Solution:
SELECT
    d.department_name,
    COUNT(e.employee_id) AS active_employee_count
FROM
    departments d
LEFT JOIN
    employees e ON d.department_id = e.department_id AND e.status = 'Active'
GROUP BY
    d.department_name
ORDER BY
    2 DESC;
-- 5. Career Progression Tracker
-- Business Case: Talent management wants to highlight internal mobility for an upcoming company newsletter. Identify all employees who have held more than one unique job title across their payroll ledger history, displaying their full name, department name, and the total number of unique titles they have held.
-- Solution:
SELECT
    e.first_name,
    e.last_name,
    d.department_name,
    COUNT(DISTINCT p.job_title) AS unique_job_titles_count
FROM
    employees e
LEFT JOIN
    departments d ON e.department_id = d.department_id
LEFT JOIN
    payroll_ledger p ON e.employee_id = p.employee_id
WHERE
    p.job_title IS NOT NULL
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
HAVING
    COUNT(DISTINCT p.job_title) > 1; 
-- 6. Hiring Anniversary Twins
-- Business Case: The culture committee wants to organize joint work-anniversary celebrations. Find pairs of different employees who share the exact same hire date. Display both employees' names and their shared hire date, ensuring you do not show duplicate reciprocal pairs (e.g., if you show Employee A paired with Employee B, do not also list Employee B paired with Employee A).
-- Solution:
SELECT
    e1.first_name AS employee1_first_name,
    e1.last_name AS employee1_last_name,
    e2.first_name AS employee2_first_name,
    e2.last_name AS employee2_last_name,
    e1.hire_date
FROM
    employees e1
JOIN
    employees e2 ON e1.hire_date = e2.hire_date AND e1.employee_id < e2.employee_id
ORDER BY
    5 DESC; 
-- 7. The Year-Over-Year Payroll Miss
-- Business Case: Compliance needs to verify payroll continuity between fiscal periods. Identify any active employees who received a paycheck during the 2013 payroll run but have absolutely no record or paycheck listed in the 2014 payroll run.
-- Solution:
SELECT
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e
LEFT JOIN departments d 
    ON e.department_id = d.department_id
WHERE EXISTS (
    SELECT 1 
    FROM payroll_ledger p13
    JOIN payroll_runs pr13 ON p13.run_id = pr13.run_id
    WHERE p13.employee_id = e.employee_id AND pr13.year = 2013
)
AND NOT EXISTS (
    SELECT 1 
    FROM payroll_ledger p14
    JOIN payroll_runs pr14 ON p14.run_id = pr14.run_id
    WHERE p14.employee_id = e.employee_id AND pr14.year = 2014
);