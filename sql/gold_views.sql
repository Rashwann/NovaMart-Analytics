CREATE OR ALTER VIEW goold.fact_sales AS
SELECT
    t.transaction_id,
    t.date,
    d.month_name,
    d.quarter,
    d.year,
    d.week_number,
    c.customer_name,
    c.region,
    c.segment,
    p.product_name,
    p.category,
    p.cost_price,
    p.selling_price,
    p.profit_margin AS product_margin_pct,
    t.quantity,
    t.unit_price,
    t.discount,
    t.total_amount,
    t.profit,
    t.profit_margin_pct AS transaction_margin_pct
FROM silveer.fact_transactions t
LEFT JOIN silveer.dim_customers c ON t.customer_id = c.customer_id
LEFT JOIN silveer.dim_products p ON t.product_id = p.product_id
LEFT JOIN bronzee.dim_date d ON t.date = d.date;
GO

CREATE OR ALTER VIEW goold.monthly_sales_summary AS
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.quantity) AS total_units_sold,
    ROUND(SUM(t.total_amount), 2) AS total_revenue,
    ROUND(SUM(t.profit), 2) AS total_profit,
    ROUND(AVG(t.profit_margin_pct), 2) AS avg_profit_margin,
    COUNT(DISTINCT t.customer_id) AS unique_customers
FROM silveer.fact_transactions t
LEFT JOIN bronzee.dim_date d ON t.date = d.date
GROUP BY d.year, d.month, d.month_name;
GO

-- View 3: Product Performance
CREATE OR ALTER VIEW goold.product_performance AS
SELECT
    p.product_name,
    p.category,
    p.selling_price,
    p.cost_price,
    p.profit_margin AS margin_pct,
    p.monthly_target_units,
    COUNT(t.transaction_id) AS total_orders,
    SUM(t.quantity) AS total_units_sold,
    ROUND(SUM(t.total_amount), 2) AS total_revenue,
    ROUND(SUM(t.profit), 2) AS total_profit,
    ROUND(SUM(t.quantity) * 100.0 /
          NULLIF(p.monthly_target_units * 24, 0), 2) AS target_achievement_pct
FROM silveer.dim_products p
LEFT JOIN silveer.fact_transactions t ON p.product_id = t.product_id
GROUP BY
    p.product_name, p.category, p.selling_price,
    p.cost_price, p.profit_margin, p.monthly_target_units;
GO

-- View 4: Customer Analysis
CREATE OR ALTER VIEW goold.customer_analysis AS
SELECT
    c.customer_id,
    c.customer_name,
    c.region,
    c.segment,
    c.join_date,
    COUNT(t.transaction_id) AS total_orders,
    SUM(t.quantity) AS total_units_bought,
    ROUND(SUM(t.total_amount), 2) AS total_spent,
    ROUND(AVG(t.total_amount), 2) AS avg_order_value,
    ROUND(SUM(t.profit), 2) AS total_profit_generated,
    MIN(t.date) AS first_purchase,
    MAX(t.date) AS last_purchase
FROM silveer.dim_customers c
LEFT JOIN silveer.fact_transactions t ON c.customer_id = t.customer_id
GROUP BY
    c.customer_id, c.customer_name, c.region,
    c.segment, c.join_date;
GO

-- View 5: Regional Performance
CREATE OR ALTER VIEW goold.regional_performance AS
SELECT
    c.region,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(t.total_amount), 2) AS total_revenue,
    ROUND(SUM(t.profit), 2) AS total_profit,
    ROUND(AVG(t.total_amount), 2) AS avg_order_value,
    ROUND(SUM(t.profit) * 100.0 /
          NULLIF(SUM(t.total_amount), 0), 2) AS profit_margin_pct
FROM silveer.dim_customers c
LEFT JOIN silveer.fact_transactions t ON c.customer_id = t.customer_id
GROUP BY c.region;
GO
