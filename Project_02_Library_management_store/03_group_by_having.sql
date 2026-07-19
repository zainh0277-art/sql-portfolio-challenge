-- Question 1: Publisher Volumetric & Quality Control Matrix
-- Business Scenario: The content acquisition team wants to evaluate the footprint of active publishers. Group the books table by publisher to find the total number of unique titles printed by each, alongside their average book rating.
-- Filter Clause: Only display publishers who have published more than 15 books in total, and sort them by their average ratings in descending order.
-- Solution:
SELECT
    publisher,
    COUNT(DISTINCT title) AS total_titles,
    AVG(rating) AS average_rating
FROM books
GROUP BY publisher
HAVING COUNT(*) > 15
ORDER BY average_rating DESC;
-- Question 2: High-Risk Genre Capital Outlay Audit
-- Business Scenario: The CFO needs to track financial exposure across literary segments. Group the books table by genre to calculate the total financial value of the asset portfolio (SUM(total_copies * purchase_cost)), and find the maximum cost price of a single book within that genre.
-- Filter Clause: Exclude genres where the total asset portfolio value is less than $1,500.
-- Solution:
SELECT
    genre,
    SUM(total_copies * purchase_cost) AS total_portfolio_value,
    MAX(purchase_cost) AS max_book_cost
FROM books
GROUP BY genre
HAVING SUM(total_copies * purchase_cost) >= 1500;
-- Question 3: Nationality Density & Historical Lifespan Matrix
-- Business Scenario: The global archiving team is analyzing author demographic distributions. Group the authors table by nationality to display the total count of registered authors and the earliest (MIN) birth year for each nation.
-- Filter Clause: Filter out any NULL nationalities before grouping, and only show regions that have at least 5 authors registered.
-- Solution:
SELECT
    nationality,
    COUNT(*) AS total_authors,
    MIN(birth_year) AS earliest_birth_year
FROM authors
WHERE nationality IS NOT NULL
GROUP BY nationality
HAVING COUNT(*) >= 5;
-- Question 4: Staff Payroll Allocation & Structural Hierarchy Analysis
-- Business Scenario: HR wants to review budget lines across corporate operational roles. Group the staff table by role to compute the total salary expenditure, average salary payroll, and the count of employees active under each role.
-- Filter Clause: Only include roles where the average salary is strictly above $35,000.
-- Solution:
SELECT
    role,
    SUM(salary) AS total_salary_expenditure,
    ROUND(AVG(salary), 2) AS average_salary,
    COUNT(*) AS employee_count
FROM staff
GROUP BY role
HAVING AVG(salary) > 35000;
-- Question 5: Granular Monthly Loan Volume Tracking
-- Business Scenario: The operations squad needs to monitor traffic fluctuations based on historical loan cycles. Group the book_loans table by the exact loan year and month to display the total count of checkouts processed.
-- Filter Clause: Only display month/year slots that handled more than 25 active loan checkouts.
-- Solution:
SELECT
    EXTRACT(YEAR FROM loan_date) AS loan_year,
    EXTRACT(MONTH FROM loan_date) AS loan_month,
    COUNT(*) AS total_checkouts
FROM book_loans
GROUP BY 1,2
HAVING COUNT(*) > 25;
-- Question 6: Defaulter Risk Profiling & Unresolved Penalties
-- Business Scenario: The credit risk department wants to flag systemic issues with outstanding balances. Group the book_loans table by member_id to sum up their total accrued_fine.
-- Filter Clause: Only show members who have accumulated a total unpaid/accrued fine strictly greater than $50.00.
-- Solution:
SELECT
    member_id,
    SUM(accrued_fine) AS total_accrued_fine
FROM book_loans
GROUP BY member_id
HAVING SUM(accrued_fine) > 50.00;
-- Question 7: Accounting Reconciliation on Payment Gateways
-- Business Scenario: The auditing firm wants to check the velocity of cash flow pipelines. Group the fine_payments table by payment_method to count the total transactions processed and the net total amount collected (SUM(amount_paid)).
-- Filter Clause: Only display payment methods that have captured a cumulative value above $200.00 (Ensure missing/unresolved payment methods are bypassed).
-- Solution:
SELECT
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(amount_paid) AS net_total_collected
FROM fine_payments
GROUP BY payment_method
HAVING SUM(amount_paid) > 200.00;
-- Question 8: Book Allocation Imbalance Monitoring
-- Business Scenario: Logistics wants to spot bottleneck points where popular books are fully exhausted. Group the books table by genre to find the average number of available_copies left on the shelves.
-- Filter Clause: Only bring forward genres where the average available copies drop below 4 units, showing high circulation pressure.
-- Solution:
SELECT
    genre,
    AVG(available_copies) AS average_available_copies
FROM books
GROUP BY genre
HAVING AVG(available_copies) < 4;