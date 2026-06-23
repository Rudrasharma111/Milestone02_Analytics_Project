
-- Card: Total Revenue
-- Answers: "How much money did we make?"
-- (Only Delivered orders count as revenue.)
SELECT
    SUM(net_revenue_amount) AS total_revenue
FROM fct_orders;


-- Card: Total Orders
-- Answers: "How many orders did we get in total?"
SELECT
    COUNT(DISTINCT unique_order_key) AS total_orders
FROM fct_orders;


-- Card: Active Customers
-- Answers: "How many different customers have placed an order?"
SELECT
    COUNT(DISTINCT customer_id) AS active_customers
FROM fct_orders;


-- Card: Total Items Sold
-- Answers: "How many total units/items did we sell?"
SELECT
    SUM(quantity) AS total_items_sold
FROM fct_orders;


-- Card: Average Order Value (AOV)
-- Answers: "On average, how much does a customer spend per order?"
SELECT
    ROUND(
        SUM(net_revenue_amount) / NULLIF(SUM(is_delivered_order), 0), 2
    ) AS average_order_value
FROM fct_orders;


-- Card: Return Rate %
-- Answers: "What % of all orders get returned?"
SELECT
    ROUND(
        SUM(is_returned_order) * 100.0
        / NULLIF(COUNT(DISTINCT unique_order_key), 0), 2
    ) AS return_rate_pct
FROM fct_orders;


-- Card: Cancellation Rate %
-- Answers: "What % of all orders get cancelled?"
SELECT
    ROUND(
        COUNT(DISTINCT CASE WHEN order_status = 'CANCELLED' THEN unique_order_key END) * 100.0
        / NULLIF(COUNT(DISTINCT unique_order_key), 0), 2
    ) AS cancellation_rate_pct
FROM fct_orders;


-- Card: Delivered Orders (count)
-- Answers: "How many orders were successfully delivered?"
SELECT
    SUM(is_delivered_order) AS delivered_orders
FROM fct_orders;


-- Card: Returned Orders (count)
-- Answers: "How many orders came back as returns?"
SELECT
    SUM(is_returned_order) AS returned_orders
FROM fct_orders;


-- Card: Cancelled Orders (count)
-- Answers: "How many orders were cancelled?"
SELECT
    COUNT(DISTINCT CASE WHEN order_status = 'CANCELLED' THEN unique_order_key END) AS cancelled_orders
FROM fct_orders;


-- Card: Avg Daily Orders
-- Answers: "On a typical day, how many orders do we get?"
SELECT
    ROUND(
        COUNT(DISTINCT unique_order_key) * 1.0 / NULLIF(COUNT(DISTINCT order_date), 0), 2
    ) AS avg_daily_orders
FROM fct_orders;


-- Card: Latest Month Revenue
-- Answers: "How much revenue did we make in the most recent month of data?"
-- (Uses the latest date actually present in our data, not today's real-world
-- date, since our dataset doesn't extend to the current calendar month.)
SELECT
    SUM(net_revenue_amount) AS latest_month_revenue
FROM fct_orders
WHERE DATE_TRUNC('month', order_date) = (
    SELECT DATE_TRUNC('month', MAX(order_date)) FROM fct_orders
);


-- Card: Inventory Health %
-- Answers: "What % of our products have a healthy stock level?"
-- (Healthy = stock_level 550 or more. Agreed threshold -- confirm before changing.)
SELECT
    ROUND(
        COUNT(CASE WHEN stock_level >= 550 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS inventory_health_pct
FROM dim_products;


-- Card: Low Stock Products (count)
-- Answers: "How many products are running low on stock?"
-- (Low = stock_level under 100.)
SELECT
    COUNT(CASE WHEN stock_level < 100 THEN 1 END) AS low_stock_products
FROM dim_products;


-- Card: Repeat Customer Rate %
-- Answers: "What % of our customers have ordered more than once?"
WITH orders_per_customer AS (
    SELECT
        customer_id,
        COUNT(DISTINCT unique_order_key) AS order_count
    FROM fct_orders
    GROUP BY customer_id
)
SELECT
    ROUND(
        COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END) * 100.0
        / NULLIF(COUNT(DISTINCT customer_id), 0), 2
    ) AS repeat_customer_rate_pct
FROM orders_per_customer;


-- ============================================================

-- Chart: Revenue Trend (line chart, by month)
-- Answers: "How has our monthly revenue moved over time, and what does
-- the recent trend (last 7 months average) look like?"
SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(net_revenue_amount) AS total_revenue,
    ROUND(
        AVG(SUM(net_revenue_amount)) OVER (
            ORDER BY DATE_TRUNC('month', order_date)
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_7month_avg
FROM fct_orders
WHERE order_date IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- Chart: Customer Retention Trend (by month)
-- Answers: "Is our repeat-customer % improving or dropping month by month?"
WITH orders_per_customer_per_month AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', order_date) AS month,
        COUNT(DISTINCT unique_order_key) AS order_count
    FROM fct_orders
    GROUP BY 1, 2
)
SELECT
    month,
    ROUND(
        COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_id END) * 100.0
        / NULLIF(COUNT(DISTINCT customer_id), 0), 2
    ) AS repeat_customer_rate_pct
FROM orders_per_customer_per_month
GROUP BY month
ORDER BY month;


-- Chart: Revenue by State (used for both the bar chart AND the map)
-- Answers: "Which states bring in the most revenue, and how fast do we
-- deliver to each?"
SELECT
    state,
    SUM(net_revenue_amount) AS total_revenue,
    COUNT(DISTINCT unique_order_key) AS total_orders,
    ROUND(AVG(delivery_days), 1) AS avg_delivery_days
FROM fct_orders
WHERE state IS NOT NULL
GROUP BY state
ORDER BY total_revenue DESC;


-- Chart: Order Status Breakdown (donut)
-- Answers: "Out of all orders, what % were Delivered vs Returned vs Cancelled?"
SELECT
    order_status,
    COUNT(DISTINCT unique_order_key) AS total_orders,
    ROUND(
        COUNT(DISTINCT unique_order_key) * 100.0
        / SUM(COUNT(DISTINCT unique_order_key)) OVER (), 2
    ) AS pct
FROM fct_orders
GROUP BY order_status;


-- Chart: Orders by Membership Type (donut)
-- Answers: "Do Platinum/Gold/Silver/Regular members order differently?"
SELECT
    dc.membership_type,
    COUNT(DISTINCT f.unique_order_key) AS total_orders,
    SUM(f.net_revenue_amount) AS total_revenue
FROM fct_orders f
JOIN dim_customers dc ON f.customer_id = dc.customer_id
GROUP BY dc.membership_type
ORDER BY total_revenue DESC;


-- Chart: Campaign Revenue (funnel)
-- Answers: "Which marketing campaign generated the most revenue?"
SELECT
    c.campaign_name,
    SUM(f.net_revenue_amount) AS campaign_revenue,
    COUNT(DISTINCT f.unique_order_key) AS total_orders
FROM fct_orders f
JOIN dim_campaigns c ON f.campaign_id = c.campaign_id
GROUP BY c.campaign_name
ORDER BY campaign_revenue DESC;


-- Chart: Campaign Performance (table)
-- Answers: "For each campaign -- how much revenue, what % of total revenue,
-- how much profit, and how healthy is it (returns/cancellations/order pace)?"
-- (Profit only counts Delivered orders, to match Gross Profit elsewhere.)
WITH campaign_stats AS (
    SELECT
        c.campaign_name,
        SUM(f.net_revenue_amount) AS campaign_revenue,
        COUNT(DISTINCT f.unique_order_key) AS total_orders,
        COUNT(DISTINCT f.order_date) AS active_days,
        SUM(f.is_returned_order) AS returned_orders,
        COUNT(DISTINCT CASE WHEN f.order_status = 'CANCELLED' THEN f.unique_order_key END) AS cancelled_orders,
        SUM(
            CASE WHEN f.is_delivered_order = 1
                 THEN f.total_amount * p.profit_margin_pct / 100
                 ELSE 0
            END
        ) AS estimated_profit
    FROM fct_orders f
    JOIN dim_campaigns c ON f.campaign_id = c.campaign_id
    JOIN dim_products p ON f.product_id = p.product_id
    GROUP BY c.campaign_name
),
company_total AS (
    SELECT SUM(net_revenue_amount) AS total
    FROM fct_orders
)
SELECT
    s.campaign_name,
    ROUND(s.campaign_revenue, 2) AS campaign_revenue,
    ROUND(s.campaign_revenue * 100.0 / NULLIF(t.total, 0), 2) AS contribution_pct,
    ROUND(s.estimated_profit, 2) AS estimated_profit,
    ROUND(s.estimated_profit * 100.0 / NULLIF(s.campaign_revenue, 0), 2) AS profit_margin_pct,
    ROUND(s.cancelled_orders * 100.0 / NULLIF(s.total_orders, 0), 2) AS cancellation_rate_pct,
    ROUND(s.returned_orders * 100.0 / NULLIF(s.total_orders, 0), 2) AS return_rate_pct,
    ROUND(s.total_orders * 1.0 / NULLIF(s.active_days, 0), 2) AS avg_daily_orders
FROM campaign_stats s
CROSS JOIN company_total t
ORDER BY campaign_revenue DESC;


-- Chart: Revenue by Product Category (column chart)
-- Answers: "Which product category sells the most?"
SELECT
    p.category,
    SUM(f.net_revenue_amount) AS total_revenue,
    COUNT(DISTINCT f.unique_order_key) AS total_orders
FROM fct_orders f
JOIN dim_products p ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- Chart: Returned Orders by Category
-- Answers: "Which product category gets returned the most?"
SELECT
    p.category,
    SUM(f.is_returned_order) AS returned_orders,
    ROUND(
        SUM(f.is_returned_order) * 100.0
        / NULLIF(COUNT(DISTINCT f.unique_order_key), 0), 2
    ) AS return_rate_pct
FROM fct_orders f
JOIN dim_products p ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY returned_orders DESC;


-- Chart: Revenue by Subcategory (Top 15)
-- Answers: "Which 15 subcategories bring in the most revenue?"
SELECT
    p.subcategory,
    SUM(f.net_revenue_amount) AS total_revenue
FROM fct_orders f
JOIN dim_products p ON f.product_id = p.product_id
GROUP BY p.subcategory
ORDER BY total_revenue DESC
LIMIT 15;


-- Chart: Revenue by Discount Bucket
-- Answers: "Do bigger discounts actually bring in more revenue/orders,
-- or just lower the average order value?"
SELECT
    discount_bucket,
    COUNT(DISTINCT unique_order_key) AS total_orders,
    SUM(net_revenue_amount) AS total_revenue,
    ROUND(
        SUM(net_revenue_amount) / NULLIF(COUNT(DISTINCT unique_order_key), 0), 2
    ) AS aov
FROM fct_orders
GROUP BY discount_bucket
ORDER BY
    CASE discount_bucket
        WHEN '0-10%' THEN 1
        WHEN '11-20%' THEN 2
        WHEN '21-30%' THEN 3
        WHEN '30%+' THEN 4
    END;


-- Chart: Revenue by Payment Method (pie chart)
-- Answers: "How do customers prefer to pay, and which method brings in
-- the most revenue?"
SELECT
    payment_method,
    SUM(net_revenue_amount) AS total_revenue,
    ROUND(
        SUM(net_revenue_amount) * 100.0 / SUM(SUM(net_revenue_amount)) OVER (), 2
    ) AS share_pct
FROM fct_orders
GROUP BY payment_method
ORDER BY total_revenue DESC;


-- Chart: Revenue by Gender & Age Group
-- Answers: "Which customer demographic (gender + age group) spends the most?"
SELECT
    dc.gender,
    dc.age_group,
    SUM(f.net_revenue_amount) AS total_revenue,
    COUNT(DISTINCT f.unique_order_key) AS total_orders
FROM fct_orders f
JOIN dim_customers dc ON f.customer_id = dc.customer_id
GROUP BY dc.gender, dc.age_group
ORDER BY total_revenue DESC;