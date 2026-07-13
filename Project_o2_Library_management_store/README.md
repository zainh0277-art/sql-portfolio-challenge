Library Management System and Transactional Analytics
Problem Statement
Traditional library software often struggles with tracking asset distribution, dynamic inventory logs, and accounting transparency. Operational bottlenecks occur when high-demand books are depleted without automated queue logs, or when penalties/fines are accumulated but lack an audit trail tracing back to the processing personnel. Additionally, user data entries frequently contain white-space anomalies and missing communication parameters that skew standard reporting.

This project implements an enterprise-ready PostgreSQL database layout that solves these operational challenges. It monitors inventory level state machines, establishes many-to-many author indexing, maps internal staff workflows (issuance and fine collection), and deploys a strict ledger tracking accrued liabilities against financial settlement modes.

authors: Stores biological data and author profiles.

books: Tracks real-time stock levels, purchase valuation costs, and consumer ratings.

book_authors: Resolves many-to-many relationship mappings between books and multiple authors.

members: Hub for user accounts, operational statuses, and subscription tiers.

staff: Internal employee registry containing payroll metrics and reporting lines.

book_loans: Core transaction ledger logging checkouts, due date boundaries, and fine calculation inputs.

book_reservations: Waitlist processing queue managing holds on out-of-stock items.

fine_payments: Cash ledger accounting trail verifying money captured by specific personnel.

Sample Data Distribution
The pipeline uses automated procedural PL/pgSQL scripts to inject mock production data across all tables. The configuration includes 150 structured book entities, 45 author records, 60 member profiles, and 200 operational loan/fine logs. The data mimics dirty production sets by adding uncleaned string spaces, unlinked contact points, and variable payment gateways to test advanced analytics scripts.

Project Directory Structure
01_library_setup.sql: Combines database schema creation and full procedural dummy data generation loops.

02_basic_queries.sql: 12 single-table data normalization, regex-parsing, and string-cleaning filters.

03_groups_having.sql: 8 aggregation queries isolating financial asset values and system bottleneck areas.

04_dashboard_analytics.sql: Production-grade multi-table joins and managerial organizational chart queries tracking corporate metrics.

Dashboard Queries and Business Analytics
Query 1: Revenue Collection Audit Trail by Operational Personnel
Business Requirement: Internal auditors need to map the cash handling trail for library fine collections, tracing paid entries back to the members who paid and the specific staff members who processed the cash.

SQL
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
Query 2: Managerial Span of Control & Subordinate Payroll (Self-Join)
Business Requirement: Corporate operations team wants to review leadership workloads and total salary responsibilities by mapping staff members directly to their reporting managers.

SQL
SELECT 
    m.staff_id AS manager_id,
    m.first_name || ' ' || m.last_name AS manager_name,
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
Query 3: High-Value Outstanding Capital Risk Report
Business Requirement: Risk management needs to audit high-cost inventory items that are currently outside the warehouse, identifying active loans where the asset cost exceeds $80.

SQL
SELECT 
    m.full_name AS member_name,
    b.title AS book_title,
    b.purchase_cost,
    bl.due_date
FROM 
    book_loans bl
JOIN 
    books b ON bl.book_id = b.book_id
JOIN 
    members m ON bl.member_id = m.member_id
WHERE 
    bl.return_date IS NULL AND b.purchase_cost > 80.00
ORDER BY 
    b.purchase_cost DESC;
Query 4: Passive Premium Accounts Exploration (Left Join Drill)
Business Requirement: Marketing engagement needs to extract premium tier members (VIP and Student status) who paid for subscriptions but have zero operational borrow footprint.

SQL
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
Query 5: Inventory Circulation Pressure by Genre
Business Requirement: Logistics managers require an analysis of checkout pressure across genres, isolating segments where the average available copies on shelves fall below critical levels.

SQL
SELECT 
    b.genre,
    COUNT(bl.loan_id) AS total_loans_processed,
    AVG(b.available_copies) AS avg_remaining_stock
FROM 
    books b
JOIN 
    book_loans bl ON b.book_id = bl.book_id
GROUP BY 
    b.genre
HAVING 
    AVG(b.available_copies) < 5.00
ORDER BY 
    total_loans_processed DESC;
How to Run
Open pgAdmin 4 and establish a clean database entity.

Open the SQL Query tool and run the files sequentially from 01 to 04.