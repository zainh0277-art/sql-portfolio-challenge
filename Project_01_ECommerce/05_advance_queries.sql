-- Task 1: Real-Time Executive Revenue Dashboard (VIEW) Scenario: Corporate board meetings require immediate access to high-level financial metrics without requiring the CEO and CFO to run complex, multi-table joins every morning. They need a ready-made virtual table that surfaces live company health statistics instantly upon execution. Requirement: Create a VIEW named vw_executive_revenue_dashboard that, whenever queried, dynamically calculates and displays each product's ID, name, total aggregated units sold, and absolute gross sales revenue (sum of quantity multiplied by unit price) directly from active ledger tables.
-- Solution:
CREATE VIEW vw_executive_revenue_dashboard AS
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS total_quantity_sold,
        SUM(oi.quantity * oi.unit_price) AS total_gross_sales_revenue
    FROM
        products p
        LEFT JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        p.product_name
    ORDER BY
        total_gross_sales_revenue DESC;

-- How to test: 
SELECT * FROM vw_executive_revenue_dashboard;

-- Task 2: Automatic Stock Deduction Radar (AFTER INSERT TRIGGER) Scenario: To eliminate manual administrative errors and keep multi-location inventory counts accurate, warehouse stock quantities must immediately adjust whenever an item transaction is confirmed. Requirement: Develop an AFTER INSERT database trigger and an accompanying trigger function on the order_items table. Logic: The moment a new transaction row is added, the trigger must execute an automated background UPDATE on the products table to systematically decrease the target product's stock_quantity by the specific number of units sold.
-- Solution:
CREATE OR REPLACE FUNCTION fn_deduct_stock_after_order_insert()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-------------------------------------------------------------------
CREATE TRIGGER trg_deduct_stock_after_order_insert
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION fn_deduct_stock_after_order_insert();
-------------------------------------------------------------------
-- Test:
SELECT * FROM products WHERE product_id = 1; -- Check stock before
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES (1, 1, 2, 10,99.87); -- Insert order item
SELECT * FROM products WHERE product_id = 1; -- Check stock after