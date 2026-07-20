-- Question 1: High-Risk User Audit Requirement: Compliance team requires a list of all registered users located in Pakistan who omitted either their email address or phone number during profile creation. The list must be sorted to prioritize the most recently registered accounts first.
-- Solution:
SELECT
    user_id,
    username,
    email,
    phone
FROM
    users
WHERE
    country = 'Pakistan' AND (email IS NULL OR phone IS NULL)
ORDER BY
    joined_date DESC;

-- Question 2: Clean Profile Report (COALESCE Practice) Requirement: Customer Relations team needs a contact list displaying usernames and phone numbers. To ensure clean formatting and maintain professional reporting standards, any missing phone number must dynamically display as 'Landline/No Phone'.
-- Solution:
SELECT
    user_id,
    username,
    COALESCE(phone, 'Landline/No Phone') AS phone_number
FROM
    users;    

-- Question 3: Under-the-Radar Financial Anomalies (Wildcards & Absolute Values) Requirement: Corporate Audit team is investigating minor financial irregularities. Filter all ledger records where the transaction description explicitly contains the words 'Audit' or 'Tax' (case-insensitive) and the financial loss or expense amount falls strictly between $50 and $500.
-- Solution:
SELECT
    financial_id,
    transaction_date,
    transaction_type,
    amount
FROM
    store_financials
WHERE
    (description ILIKE '%audit%' OR description ILIKE '%tax%')
    AND amount BETWEEN -500 AND -50
ORDER BY
    amount ASC;

-- Question 4: Inventory Alert (Low Stock & Out of Stock) Requirement: Warehouse Logistics Manager needs an inventory depletion report pinpointing items that are completely out of stock (quantity = 0) or sitting at critical levels (quantity between 1 and 20 units). Critical stock items must be prioritized and displayed before out-of-stock items.
-- Solution:
SELECT
    product_id,
    product_name,
    stock_quantity,
    CASE
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN stock_quantity BETWEEN 1 AND 20 THEN 'Low Stock'
    END AS stock_status
FROM
    products
WHERE
    stock_quantity = 0 OR stock_quantity BETWEEN 1 AND 20
ORDER BY
    CASE
        WHEN stock_quantity BETWEEN 1 AND 20 THEN 1
        WHEN stock_quantity = 0 THEN 2
    END,
    stock_status DESC;

-- Question 5: Financial Risk Tracker (Large Expenses) Requirement: Finance Department requires a breakdown of high-value operational expenses where the company spent more than $100 in a single transaction. Since expenses are recorded as negative values, filter appropriately and rank the largest absolute cash outflows at the top.
-- Solution:
SELECT
    financial_id,
    transaction_date,
    transaction_type,
    amount
FROM
    store_financials
WHERE
    transaction_type = 'Expense' AND amount < -100
ORDER BY
    ABS(amount) DESC;

-- Question 6: International Fraud Control & Non-Standard Emails Requirement: Risk Audit team wants to isolate potential fake user profiles to prevent business data leakage. Extract the user_id, username, and email of all users who are NOT from Pakistan or India, whose email addresses do NOT end with standard domains like @gmail.com or @yahoo.com, and who registered after the year 2025.
-- Solution:
SELECT
    user_id,
    username,
    email
FROM
    users
WHERE
    country NOT IN ('Pakistan', 'India')
    AND email NOT LIKE '%@gmail.com'
    AND email NOT LIKE '%@yahoo.com'
    AND joined_date > '2025-12-31';

-- Question 7: Projections on Planned Appraisals (Salary Math & Offsets) Requirement: HR Department is drafting the annual compensation budget. They need to model a scenario where every employee receives a 14% salary hike along with a flat $500 allowance bonus, and identify which specific employees will see their projected total compensation exceed $85,000.
-- Solution:
SELECT
    first_name || ' ' || last_name AS Full_name,
    salary AS Current_Salary,
    ROUND((salary * 1.14 + 500), 2) AS Projected_Salary
FROM
    employees
WHERE
    (salary * 1.14 + 500) > 85000
ORDER BY
    Projected_Salary DESC;

-- Question 8: Executive Formatting Clean-up (Advanced String Control) Requirement: Data Engineering team needs to clean and standardize employee records for an executive review. Generate a report where the first name is forced to complete uppercase, the last name is forced to complete lowercase, filtered only for the Sales, Marketing, and Finance departments, and restricted to odd-numbered employee IDs.
-- Solution:
SELECT
    UPPER(first_name) AS first_name_uppercase,
    LOWER(last_name) AS last_name_lowercase,
    department,
    employee_id
FROM
    employees
WHERE
    department IN ('Sales', 'Marketing', 'Finance')
    AND employee_id % 2 = 1;

-- Question 9: Hidden Financial Anomalies (Wildcard Substring Search) Requirement: Tax investigators require a complete data extract from the store financials ledger to perform a deep forensic audit. Filter all rows where the description contains the terms 'Audit', 'Tax', or 'Penalty' (case-insensitive) and the absolute spending amount ranges strictly between $150 and $750.
-- Solution:
SELECT
    financial_id,
    transaction_date,
    transaction_type,
    amount,
    description
FROM
    store_financials
WHERE
    (description ILIKE '%audit%' OR description ILIKE '%tax%' OR description ILIKE '%penalty%')
    AND amount BETWEEN -750 AND -150;

-- Question 10: Dynamic Seniority Banding (CASE WHEN Date Control) Requirement: Business Operations team wants to analyze corporate user retention cohorts. Generate a user list categorizing tenures dynamically: users registering before 2024 must show as 'OG Legacy', users joining during 2024 or 2025 must show as 'Mid-Term Core', and all subsequent sign-ups must show as 'Recent Acquisition'.
-- Solution:
SELECT
    username,
    country,
    CASE
        WHEN joined_date < '2024-01-01' THEN 'OG Legacy'
        WHEN joined_date BETWEEN '2024-01-01' AND '2025-12-31' THEN 'Mid-Term Core'
        ELSE 'Recent Acquisition'
    END AS retention_tier
FROM
    users;