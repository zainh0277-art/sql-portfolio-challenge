-- Question 1: Co-Authored Masterpieces & Asset Distribution (Many-to-Many Bridge)
-- Business Scenario: The cataloging department wants to identify complex intellectual property assets. Write a query to find all books that have more than 1 author assigned to them.
-- Requirement: Display the book title, genre, and the total count of authors who wrote it. Only include books where the total author count is strictly greater than 1.
-- Solution:
SELECT
    b.title,
    b.genre,
    COUNT(a.author_id)
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON a.author_id = ba.author_id
GROUP BY
    b.title,
    b.genre
HAVING
    COUNT(a.author_id) > 1;
-- Question 2: High-Value Outstanding Capital Risk Report (3-Table Operational Join)
-- Business Scenario: Risk management needs to audit high-cost inventory currently outside the warehouse. Generate a report showing currently unreturned book loans (return_date IS NULL) where the book's purchase_cost is above $80.
-- Requirement: Display the member's full_name, book title, purchase_cost, and the due_date. Sort the output by the highest purchase cost.
-- Solution:
SELECT
    m.full_name AS member_name,
    b.title,
    b.purchase_cost,
    bl.due_date
FROM members m
INNER JOIN book_loans bl ON bl.member_id = m.member_id
INNER JOIN books b ON b.book_id = bl.book_id
WHERE
    b.purchase_cost > 80 AND bl.return_date IS NULL
ORDER BY
    b.purchase_cost DESC;
-- Question 3: Managerial Span of Control & Subordinate Payroll (Self-Join + Aggregation)
-- Business Scenario: The corporate operations team wants to analyze workload and financial responsibility among management. Write a self-join query on the staff table to list every manager's full name and role.
-- Requirement: Display the Manager's Full Name, their role, the total number of employees directly reporting to them, and the combined cumulative salary (SUM) of those subordinates. Exclude managers who have no reporting staff.
-- Solution:
SELECT 
    m.first_name || ' ' || m.last_name AS manager_full_name,
    m.role AS manager_role,
    COUNT(e.staff_id) AS total_subordinates,
    SUM(e.salary) AS total_subordinate_payroll
FROM 
    staff m
JOIN 
    staff e ON e.managed_by = m.staff_id
GROUP BY 
    m.staff_id, m.first_name, m.last_name, m.role
ORDER BY 
    total_subordinates DESC;
-- Question 4: Revenue Collection Audit Trail by Operational Personnel (4-Table Complete Ledger Join)
-- Business Scenario: Internal auditors are verifying the cash handling trail for library fine collections. Write a query to trace fine payments back to the staff members who processed them and the members who paid them.
-- Requirement: Display the payment_id, Member's full_name, Book title, amount_paid, payment_method, and the Staff Member's first_name (who processed the payment).
-- Solution:
SELECT 
    fp.payment_id,
    m.full_name AS member_name,
    b.title AS book_title,
    fp.amount_paid,
    fp.payment_method,
    s.first_name AS processed_by_staff
FROM 
    fine_payments fp
JOIN 
    book_loans bl ON fp.loan_id = bl.loan_id
JOIN 
    members m ON bl.member_id = m.member_id
JOIN 
    books b ON bl.book_id = b.book_id
JOIN 
    staff s ON fp.processed_by = s.staff_id
ORDER BY 
    fp.payment_id ASC;
-- Question 5: Passive Premium Accounts Exploration (LEFT JOIN Drill)
-- Business Scenario: The engagement team wants to launch a marketing campaign targeting high-tier members who paid for subscriptions but are completely inactive. Find all members under the 'VIP' or 'Student' tiers who have NEVER borrowed a single book.
-- Requirement: Use a LEFT JOIN between members and book_loans to extract the member's full_name, email, and membership_tier where no loan record exists.
-- Solution:
SELECT 
    m.full_name,
    m.email,
    m.membership_tier
FROM 
    members m
LEFT JOIN 
    book_loans bl ON m.member_id = bl.member_id
WHERE 
    bl.loan_id IS NULL 
    AND m.membership_tier IN ('VIP', 'Student')
ORDER BY 
    m.full_name ASC;