-- Question 1: Identifying Irregular Doctor Profiles 
-- Business Scenario: The library administration wants to audit authors who are registered with professional titles but lack descriptive content. Write a query to find all authors whose names contain 'Dr.' (case-insensitive) but their biography column is NULL.
-- Solution:
SELECT * FROM authors
WHERE author_name ILIKE '%Dr.%' AND biography IS NULL;
-- Question 2: Rogue/Anonymous Email Domain Investigation
-- Business Scenario: The security team is tracking anonymous or junk accounts. Extract the member_id, full_name, and email of all members whose emails do NOT end with @lib.org and whose phone numbers are missing (NULL).
-- Solution:
SELECT member_id, full_name, email FROM members
WHERE email NOT LIKE '%@lib.org' AND phone IS NULL;
-- Question 3: High-Value Inventory Financial Risk Exposure
-- Business Scenario: The procurement department needs to review expensive items with zero user feedback. Filter all books that have a purchase_cost strictly greater than $100, but their public rating is completely NULL. Sort the list with the highest cost on top.
-- Solution:
SELECT * FROM books
WHERE purchase_cost > 100 AND rating IS NULL
ORDER BY purchase_cost DESC;
-- Question 4: Standardizing Messy Data Fields
-- Business Scenario: Due to a legacy data entry issue, some author names have accidental leading or trailing white spaces. Write a query that returns the author_id, and a clean version of the author_name using trimming functions, but only for authors who do NOT belong to the 'United States' or 'United Kingdom'.
-- Solution:
SELECT author_id, TRIM(author_name) AS clean_author_name
FROM authors
WHERE nationality NOT IN ('United States', 'United Kingdom');
-- Question 5: Outdated Fiction Stock Assessment
-- Business Scenario: The logistics manager wants to prune the old storage racks. Display the title, isbn, and available_copies of all books belonging to the 'Fiction' genre that were published before the year 2010 and currently have more than 5 copies available in stock.
-- Solution:
SELECT title, isbn, available_copies
FROM books
WHERE genre = 'Fiction' AND publication_year < 2010 AND available_copies > 5;
-- Question 6: Tracking High-Impact Late Return Financials
-- Business Scenario: The treasury branch wants to review unpaid heavy penalties. Search the book_loans table for all transactions where the accrued_fine is between $20.00 and $50.00 inclusive, but the book has NOT been returned yet (return_date is NULL).
-- Solution:
SELECT
    * 
FROM book_loans
    WHERE accrued_fine BETWEEN 20.00 AND 50.00 AND return_date IS NULL;
-- Question 7: Odd-ID Suspended Member Profiles
-- Business Scenario: The operations squad is running a batch script validation on internal IDs. Select all members whose status is currently 'Suspended', but filter the results to only include those whose member_id is an ODD number (e.g., 1, 3, 5...).
-- Solution:
SELECT * FROM members
WHERE status = 'Suspended' AND member_id % 2 <> 0;
-- Question 8: Substring Pattern Mining for Specific Series
-- Business Scenario: A publishing partner wants to know the performance of specific technical segments. Write a query to find all books whose titles contain the specific word 'Architecture' or 'Algorithms' (case-insensitive) and their total copies are less than 7.
-- Solution:
SELECT * FROM books
WHERE (title ILIKE '%Architecture%' OR title ILIKE '%Algorithms%') AND total_copies < 7;
-- Question 9: High-Earner Executive Payroll Audit
-- Business Scenario: The compensation committee wants to evaluate staff records for high payroll outlays. Filter all personnel from the staff table whose basic salary is strictly above $45,000 and ensure they were hired after the year 2023.
-- Solution:
SELECT
    *
FROM staff
WHERE salary > 45000 AND hire_date > '2023-12-31';
-- Question 10: Post-Pandemic Account Lifetime Milestone
-- Business Scenario: The CRM system wants to track user retention metrics based on subscription longevity. Filter all members who joined the library after December 31, 2024, hold a 'VIP' or 'Student' membership tier, and whose accounts are currently 'Active'.
-- Solution:
SELECT
    *
FROM members
WHERE membership_date > '2024-12-31' AND membership_tier IN ('VIP', 'Student') AND status = 'Active';
-- Question 11: Unresolved Anonymous Fine Payment Slips
-- Business Scenario: Internal accounting detected fine payments processed without structural payment tracking methods. Extract all transactions from the fine_payments table where the amount_paid is greater than $10.00, but the payment_method is recorded as NULL.
-- Solution:
SELECT
    *
FROM
    fine_payments
    WHERE amount_paid > 10.00 AND payment_method IS NULL;
-- Question 12: Absolute Year Deviation Checklist
-- Business Scenario: The historical archiving team wants to trace the birth patterns of senior authors. Find all authors whose birth_year is between 1950 and 1980 (inclusive) and ensure their nationality is explicitly recorded (is NOT NULL).
-- Solution:
SELECT
    *
FROM authors
WHERE birth_year BETWEEN 1950 AND 1980 AND nationality IS NOT NULL;