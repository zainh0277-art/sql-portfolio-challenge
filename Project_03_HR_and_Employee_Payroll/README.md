# Enterprise HR and Payroll Analytics Platform
This repository serves as a production-grade SQL analytics environment designed to extract clear intelligence from corporate HR and financial data streams. The core objective is to identify cost overruns, map internal management hierarchies, and uncover database anomalies that frequently slip through standard reporting tools.

# Analytical Architecture and Context
The analytical engine operates across three core relational tables within the database schema:

departments: Defines organizational boundaries, cost centers, and business units.

employees: Tracks worker profiles, employment lifecycle statuses, historical hire windows, and reporting lines via recursive manager identification keys.

payroll_ledger: Captures granular, historical financial transactions, isolating base salaries, localized overtime metrics, and benefits packages across multiple fiscal years.

Technical Progression
The analytical roadmap is structured into three specific developmental phases, demonstrating an evolution from standard querying to complex data engineering solutions.

# Phase 1: Foundational Filtering and Trends
The initial phase establishes baseline metrics. Queries are written to audit worker tenure, separate active talent pools from terminated accounts, map job roles, and sort compensation distributions to establish baseline payroll parameters.

# Phase 2: Dynamic Benchmarking via Subqueries
The scope shifts to comparative analysis by nesting subqueries directly inside HAVING clauses. This allow the system to evaluate group aggregates against shifting global benchmarks in a single execution block. Key outcomes include isolating departments outspending the company-wide salary average and flagging specific job titles that have over-saturated headcounts compared to the organizational mean.

# Phase 3: Advanced Relational Mapping and Complex Joins
The final layer implements advanced relational logic to fix systemic administrative blind spots and handle matrix reporting. This involves complex data operations designed for deep-dive auditing.

# Business Value and Scenarios Solved
The SQL scripts in this suite translate raw transactional logs into high-level organizational insights, solving several critical corporate scenarios:

Departmental Budget Verification: Aggregates complete multi-year spending reports across base salaries, benefits, and overtime to track the true operational cost of each business unit.

System Integrity Auditing: Leverages left exclusion joins to detect structural errors, such as ghost departments holding zero staff or active employees who are completely missing from the payroll ledger during onboarding phases.

Organizational Charting and Spans of Control: Uses recursive self-joins to map exact supervisor-to-report lines, count management direct-report densities, and flag equity anomalies where an employee out-earns their direct manager.

Cross-Functional Training Projections: Deploys Cartesian products via cross-joins to systematically pair workforce cohorts against various corporate departments for training rotation matrices.

Time-Series Continuity Testing: Evaluates consecutive payroll years to isolate retention anomalies, catching instances where an employee received payouts in a prior fiscal year but has no registered activity in the following period.