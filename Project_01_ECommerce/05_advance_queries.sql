-- Task 1: Real-Time Executive Revenue Dashboard (VIEW) Scenario: Corporate board meetings mein CEO aur CFO roz subah uth kar complex multi-table joins nahi chalana chahte. Unhein aik ready-made virtual table chahiye jise call karte hi live company status samne aa jaye. Requirement: Aik VIEW banao jiska naam ho vw_executive_revenue_dashboard. Logic: Yeh view jab bhi SELECT kiya jaye, yeh har product ka product_id, product_name, bechi gayi kul total quantity, aur generate hone wala kul gross sales revenue (quantity * unit_price ka sum) live tables se calculate kar ke display kare.
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
-- Task 2: Automatic Stock Deduction Radar (AFTER INSERT TRIGGER Scenario: Jab order item table mein successfully entry ho jaye, tu warehouse ke stock mein se utni quantity khud-ba-khud minus ho jani chahiye taake manual updates na karni paren. Requirement: order_items table par aik AFTER INSERT trigger aur trigger function banao. Logic: Jaise hi order successfully insert ho, yeh trigger automatic piche products table par aik UPDATE query chalaye jo us specific product_id ki stock_quantity ko beche gaye units ke mutabiq decrease (minus) kar de.
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