-- LAGOSLINK EXPRESS LAST-MILE DELIVERY PERFORMANCE ANALYSIS
-- Database: LagosLastMileDB
-- Author: Abdulsamad Kudehinbu Mobolaji


-- SECTION 3: OVERALL DELIVERY PERFORMANCE

/* 
With the data validated, meaningful insights can then be extracted.
This section establishes the top-level KPIs, the headline numbers that
 provides a complete picture of the LagosLink Express's operational performance acroos the full two-year period.
*/

-- 3.1 Top-Level KPIs
-- A single query is used to display the six most important operational metrics

SELECT
	COUNT(*) AS total_orders,
	SUM(CASE WHEN delivery_status = 'Delivered' THEN 1 ELSE 0 END)
AS successful_deliveries,
	SUM(CASE WHEN delivery_status = 'Failed' THEN 1 ELSE 0 END)
AS failed_deliveries,
	ROUND(
	SUM(CASE WHEN delivery_status = 'Delivered' THEN 1.0 ELSE 0 END)
	/COUNT(*) * 100, 2)
AS success_rate_pct,
	ROUND(AVG(CAST(actual_time_minutes AS FLOAT)),1)
AS avg_delivery_time_mins,
	SUM(CASE WHEN sla_breached = 1 THEN 1.0 ELSE 0 END)
AS total_sla_breaches,
	ROUND(
	SUM(CASE WHEN sla_breached = 1 THEN 1.0 ELSE 0 END) /
	NULLIF(SUM(CASE WHEN delivery_status = 'Delivered' THEN 1 ELSE 0 END), 0) * 100, 2)
AS sla_breach_rate_pct,
	SUM(CASE WHEN attempt_number = 2 THEN 1 ELSE 0 END)
AS second_attempt_orders
FROM 
	fact_deliveries;


-- 3.2 Delivery Performance by vehicle
/*
Breaking down success rate and average delivery time by vehicle type gives early signal on 
whether motocycles, vans, or biclycles are driving operational efficiency or dragging it down.
*/

SELECT
	c.vehicle_type,
	COUNT(f.order_id) AS total_orders,
	SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered,
	SUM(CASE WHEN f.delivery_status = 'Failed' THEN 1 ELSE 0 END) AS failed,
	ROUND(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END) / COUNT(f.order_id)
	* 100, 2) AS success_rate_pct,
	ROUND(AVG(CAST(f.actual_time_minutes AS FLOAT)), 1) AS avg_delivery_mins,
	SUM(CASE WHEN f.sla_breached = 1 THEN 1 ELSE 0 END) AS sla_breaches
FROM
	fact_deliveries AS f
JOIN 
	dim_courier AS c 
	ON f.courier_id = c.courier_id
GROUP BY 
	c.vehicle_type
ORDER BY
	success_rate_pct DESC;

-- 3.3 Second Attempt Analysis
/* 
Orders that required a second delivery attempt represent additional operational cost. This 
query breaks down how many second attempts were made, how many ultimately succeeded, and 
what the recovery rate looks like overall.
*/

SELECT 
	COUNT(*) AS total_second_attempts,
	SUM(CASE WHEN delivery_status = 'Delivered' THEN 1 ELSE 0 END) AS recovered,
	SUM(CASE WHEN delivery_status = 'Failed' THEN 1 ELSE 0 END) AS still_failed,
	ROUND(SUM(CASE WHEN delivery_status = 'Delivered' THEN 1.0 ELSE 0 END)
	/COUNT(*) * 100, 2) AS recovery_rate_pct
FROM
	fact_deliveries
WHERE attempt_number = 2;

-- 3.4 Performance on Public Holidays vs Regular Days
/*
Public Holidats in Lagos,Nigeria introduce unique operational challenges such as reduced 
courier availability, heavier traffic traffic around market areas, and unpredictable customer 
avilability. This query investigates whether holiday periods meaningfully impact delivery 
outcomes.
*/

SELECT 
	CASE WHEN d.is_public_holiday = 1 THEN 'Public Holiday' ELSE 'Regular Day' END 
	AS day_type,
	COUNT(f.order_id) AS total_orders,
	ROUND(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END)/
	COUNT(f.order_id) * 100, 2) AS success_rate_pct,
	ROUND(AVG(CAST(f.actual_time_minutes AS FLOAT)), 1) AS avg_delivery_mins,
	SUM(CASE WHEN f.sla_breached = 1 THEN 1 ELSE 0 END) AS sla_breaches
FROM 
	fact_deliveries AS f
JOIN 
	dim_date AS d
	ON f.date_id = d.date_id
GROUP BY 
	d.is_public_holiday
ORDER BY 
	day_type;



















