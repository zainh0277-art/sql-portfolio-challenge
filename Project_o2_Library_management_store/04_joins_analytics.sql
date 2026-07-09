-- Question 1: Co-Authored Masterpieces & Asset Distribution (Many-to-Many Bridge)
-- Business Scenario: The cataloging department wants to identify complex intellectual property assets. Write a query to find all books that have more than 1 author assigned to them.
-- Requirement: Display the book title, genre, and the total count of authors who wrote it. Only include books where the total author count is strictly greater than 1.
-- Solution:

-- Question 2: High-Value Outstanding Capital Risk Report (3-Table Operational Join)
-- Business Scenario: Risk management needs to audit high-cost inventory currently outside the warehouse. Generate a report showing currently unreturned book loans (return_date IS NULL) where the book's purchase_cost is above $80.
-- Requirement: Display the member's full_name, book title, purchase_cost, and the due_date. Sort the output by the highest purchase cost.
-- Solution:

-- Question 3: Managerial Span of Control & Subordinate Payroll (Self-Join + Aggregation)
-- Business Scenario: The corporate operations team wants to analyze workload and financial responsibility among management. Write a self-join query on the staff table to list every manager's full name and role.
-- Requirement: Display the Manager's Full Name, their role, the total number of employees directly reporting to them, and the combined cumulative salary (SUM) of those subordinates. Exclude managers who have no reporting staff.
-- Solution:

-- Question 4: Revenue Collection Audit Trail by Operational Personnel (4-Table Complete Ledger Join)
-- Business Scenario: Internal auditors are verifying the cash handling trail for library fine collections. Write a query to trace fine payments back to the staff members who processed them and the members who paid them.
-- Requirement: Display the payment_id, Member's full_name, Book title, amount_paid, payment_method, and the Staff Member's first_name (who processed the payment).
-- Solution:

-- Question 5: Passive Premium Accounts Exploration (LEFT JOIN Drill)
-- Business Scenario: The engagement team wants to launch a marketing campaign targeting high-tier members who paid for subscriptions but are completely inactive. Find all members under the 'VIP' or 'Student' tiers who have NEVER borrowed a single book.
-- Requirement: Use a LEFT JOIN between members and book_loans to extract the member's full_name, email, and membership_tier where no loan record exists.
-- Solution:

-- Question 6: Cross-Genre Versatile Authors Profiling (Multi-Bridge Grouping)
-- Business Scenario: The editorial board wants to reward highly versatile writers who contribute across multiple literary segments. Identify authors who have written books in more than 2 distinct genres.
-- Requirement: Join authors, book_authors, and books to list the author_name, nationality, and the count of unique genres they have published in.
-- Solution:

-- Question 7: Unfulfilled High-Demand Waitlist Backlog (Conditional Joins)
-- Business Scenario: Logistics needs to order urgent inventory reprints for popular titles that are completely out of stock but have users waiting in the queue.
-- Requirement: Join books with book_reservations. Filter for books where available_copies = 0 and the reservation status is 'Pending'. Display the book title, genre, and the total count of pending holds.
-- Solution:

-- Question 8: Unsettled Penalties & Ledger Discrepancy Analytics (Fines vs. Payments)
-- Business Scenario: Finance wants to flag accounts where an accrued fine exists on a loan, but no matching successful payment transaction has been recorded in the ledger table.
-- Requirement: Perform a LEFT JOIN from book_loans to fine_payments. Find records where accrued_fine > 0 but the payment_id is NULL (meaning the fine is completely unpaid). Display the loan_id, member_id, and the outstanding accrued_fine.
-- Solution:

-- Question 9: High-Velocity Staff Issuance Performance Metrics (Staff -> Loans Focus)
-- Business Scenario: HR is calculating quarterly performance bonuses for operational librarians based on check-out processing volumes.
-- Requirement: Join staff and book_loans to find the total number of loans processed by each staff member. Display the staff member's full name, role, and the total loans count, but only for staff members who have processed more than 10 loans in total.
-- Solution:

-- Question 10: Complete System Synchronization & Late Returns Flow (5-Table Monster Join)
-- Business Scenario: The executive dashboard requires a comprehensive operational view of system bottlenecks—specifically tracing severe late returns.
-- Requirement: Write a 5-table join (members + book_loans + books + staff + fine_payments) to extract details of members who returned books late (accrued_fine > 0). Display Member Name, Book Title, Staff Name who issued it, Fine Amount, and the Payment Method used to clear it.
-- Solution: