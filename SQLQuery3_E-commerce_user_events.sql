-- To explore the top 10 rows

SELECT TOP 10 *
FROM PortfolioProjects..user_events


-- How many traffic sources do we have (These are the means through which potential customers hear of our business to visit our website)

SELECT DISTINCT traffic_source
FROM PortfolioProjects.dbo.user_events


-- What are the various steps one has to go through to complete a purchase

SELECT DISTINCT event_type
FROM PortfolioProjects.dbo.user_events


-- How many steps are there to complete a purchase (a full purchase cycle)

SELECT COUNT(DISTINCT event_type)
FROM PortfolioProjects.dbo.user_events


-- Number of completed purchase per traffic source (This is to see which traffic source account for the most purchase - Organic leads the chart)

SELECT traffic_source, COUNT(traffic_source) AS purchase_count
FROM PortfolioProjects.dbo.user_events
WHERE amount IS NOT NULL
GROUP BY traffic_source
ORDER BY purchase_count DESC


-- Number of completed purchase per traffic source (this second query is used as a checker, it should return the same results as the query above it)

SELECT traffic_source, COUNT(traffic_source) AS purchase_count
FROM PortfolioProjects.dbo.user_events
WHERE event_type = 'purchase'
GROUP BY traffic_source
ORDER BY purchase_count DESC


-- Total number of users that visited our website

SELECT COUNT(DISTINCT user_id) AS total_visits
FROM PortfolioProjects.dbo.user_events


-- Number of visitors that made a purchase

SELECT COUNT(user_id) AS users_who_purchased
FROM PortfolioProjects.dbo.user_events
WHERE event_type = 'purchase'


-- List of users that completed a purchase to reach out to them to see how we could improve the user experience on the website

SELECT user_id
FROM PortfolioProjects.dbo.user_events
WHERE event_type = 'purchase'


-- List of users that did not complete a purchase (to reach out to them to understand the reasons for that inorder to improve the products, services or website etc)

SELECT user_id
FROM PortfolioProjects.dbo.user_events
WHERE user_id NOT IN (SELECT user_id FROM PortfolioProjects.dbo.user_events WHERE event_type = 'purchase')

-- Number of visitors that did not complete a purchase 

SELECT COUNT(DISTINCT user_id)
FROM PortfolioProjects.dbo.user_events
WHERE user_id NOT IN (SELECT user_id FROM PortfolioProjects.dbo.user_events WHERE event_type = 'purchase')


-- Number of purchases per product id (This is to see the product id with the most purchases)

SELECT product_id, COUNT(product_id) AS count
FROM PortfolioProjects.dbo.user_events
WHERE event_type = 'purchase'
GROUP BY product_id
ORDER BY count DESC


-- Views Vrs Purchases comparison (to check if the product with the most views has the highest number of purchase)

SELECT 
    product_id,
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchases
FROM PortfolioProjects.dbo.user_events
GROUP BY product_id
ORDER BY views DESC


-- define sales funnel and the different stages (will employ a Common Table Expression - CTE for this)
-- This should tell us whether we are losing users as we go through the purchase cycle

WITH purc_stage AS (
    SELECT 
        COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS step1_views,
        COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS step2_cart,
        COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS step3_checkout,
        COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS step4_payment,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS step5_purchase
    FROM PortfolioProjects.dbo.user_events
)
SELECT * FROM purc_stage


-- Conversion rates in terms of the various stages of purchases

WITH purc_stages AS (
    SELECT
        COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS step1_views,
        COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS step2_cart,
        COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS step3_checkout,
        COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS step4_payment,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS step5_purchase
    FROM PortfolioProjects.dbo.user_events
    )
SELECT 
    step1_views,
    step2_cart,
    ROUND(step2_cart * 100 / step1_views,1) AS view_to_cart_rate,

    step3_checkout,
    ROUND(step3_checkout * 100 / step2_cart,1) AS cart_to_checkout_rate,

    step4_payment,
    ROUND(step4_payment * 100 / step3_checkout,1) AS checkout_to_payment_rate,

    step5_purchase,
    ROUND(step5_purchase * 100 / step4_payment,1) AS purchase_to_payment_rate,

    ROUND(step5_purchase * 100 / step1_views,1) AS overall_conversion

FROM purc_stages


-- Traffic source funnel
-- This is to evaluate which source is most effective in driving purchases using conversion rate and also identifying which medium drives traction to our website

WITH traffic_source AS (
    SELECT traffic_source,
        COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
        COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS cart,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchases
    FROM PortfolioProjects.dbo.user_events
    GROUP BY traffic_source
)
SELECT
    traffic_source,
    views,
    cart,
    purchases,
    ROUND(cart * 100 / views, 1) AS cart_conver_rate,
    ROUND(purchases * 100 / views, 1) AS purch_conver_rate,
    ROUND(purchases * 100 / cart, 1) AS cart_to_purc_conver_rate
FROM traffic_source
ORDER BY purchases DESC
   

-- time to conversion analyis, determine how long a vistor takes to complete a purchase cycle

WITH customer_journey AS (
    SELECT user_id,
        MIN(CASE WHEN event_type = 'page_view' THEN event_date END) AS view_time,
        MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END) AS cart_time,
        MIN(CASE WHEN event_type = 'purchase' THEN event_date END) AS purchase_time
    FROM PortfolioProjects.dbo.user_events
    GROUP BY user_id
    HAVING MIN(CASE WHEN event_type = 'purchase' THEN event_date END) IS NOT NULL
)
SELECT
COUNT(*) AS converted_users,
AVG(DATEDIFF(minute, view_time, cart_time)) AS avg_view_to_cart,
AVG(DATEDIFF(minute, cart_time, purchase_time)) AS avg_cart_to_purchase,
AVG(DATEDIFF(minute, view_time, purchase_time)) AS avg_view_to_purchase
FROM customer_journey


-- Revenue analysis; Total revenue, total orders, total visitors, total purchases etc

WITH revenue_analy AS(
    SELECT
        COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS total_visitors,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS total_buyers,
        COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS total_orders,
        SUM(CASE WHEN event_type = 'purchase' THEN amount END) AS total_revenue
    FROM PortfolioProjects.dbo.user_events
)
SELECT 
    total_visitors,
    total_buyers,
    total_orders,
    ROUND(total_revenue,1),
    ROUND(total_revenue / total_orders,1) AS avg_order_value,
    ROUND(total_revenue / total_buyers,1) AS revenue_per_buyer
FROM revenue_analy