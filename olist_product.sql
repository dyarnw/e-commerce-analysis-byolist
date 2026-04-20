CREATE OR REPLACE VIEW v_product_analysis AS
SELECT
    o.order_id,
    o.order_purchase_timestamp,
    oi.product_id,
    oi.seller_id,
    p.product_category_name,
    COALESCE(t.product_category_name_english, p.product_category_name) AS category_name,
    oi.price,
    oi.freight_value
FROM orders o
JOIN order_items oi 
    ON o.order_id = oi.order_id
LEFT JOIN products p 
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered';



SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';
SELECT * FROM v_orders_kpi LIMIT 10;
SELECT * FROM v_product_analysis LIMIT 10;

