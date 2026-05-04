-- LAGOSLINK EXPRESS LAST-MILE DELIVERY PERFORMANCE ANALYSIS
-- Database: LagosLastMileDB
-- Author: Abdulsamad Kudehinbu Mobolaji


-- SECTION 4: ZONE PERFORMANCE ANALYSIS
/*
Lagos is not a uniform environment. Traffic congestion, road infrastructure, and zone geography
vary significantly across the city. This section breaks down performance by zone to identify where
the company is struggling and where it is operating well.
*/

-- 4.1 Delivery success rate and average delivery time by zone

SELECT
	z.zone_name,
	z.zone_type,
	z.congestion_level,
	COUNT(f.order_id) AS total_orders,
	SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered,
	SUM(CASE WHEN f.delivery_status = 'Failed' THEN 1 ELSE 0 END) AS failed,
	ROUND(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END) 
	/ COUNT(f.order_id) * 100, 2) AS success_rate_pct,
	ROUND(AVG(CAST(f.actual_time_minutes AS FLOAT)),1) AS avg_delivery_mins,
	SUM(CASE WHEN f.sla_breached = 1 THEN 1 ELSE 0 END) AS sla_breaches,
	ROUND(SUM(CASE WHEN f.sla_breached = 1 THEN 1.0 ELSE 0 END)
	/ NULLIF(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1 ELSE 0 END), 0) * 100, 2) 
	AS sla_breach_rate_pct
FROM 
	fact_deliveries AS f
JOIN 
	dim_zone AS z
	ON f.zone_id = z.zone_id
GROUP BY 
	z.zone_name, z.zone_type, z.congestion_level
ORDER BY 
	success_rate_pct ASC;


-- 4.2 Zone ranking by failure rate

WITH zone_stats AS (
	SELECT
		z.zone_name,
		z.congestion_level,
		COUNT(f.order_id) AS total_orders,
		ROUND(SUM(CASE WHEN f.delivery_status = 'Failed' THEN 1.0 ELSE 0 END)
		/ COUNT(f.order_id) * 100, 2) AS failure_rate_pct
	FROM
		fact_deliveries AS f
	JOIN
		dim_zone AS z
		ON f.zone_id = z.zone_id
	GROUP BY 
		z.zone_name, z.congestion_level
	)
SELECT
	zone_name,
	congestion_level,
	total_orders,
	failure_rate_pct,
	RANK() OVER (ORDER BY failure_rate_pct DESC)
AS failure_rank
FROM zone_stats
ORDER BY failure_rank;


-- 4.3 Island vs Mainland Performance comparison

SELECT
	z.zone_type,
	COUNT(f.order_id) AS total_orders,
	ROUND(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END)/
	COUNT(f.order_id) * 100, 2) AS success_rate_pct,
	ROUND(AVG(CAST(f.actual_time_minutes AS FLOAT)), 1) AS avg_delivery_mins,
	AVG(f.sla_target_minutes) AS sla_target_mins,
	ROUND(AVG(CAST(f.actual_time_minutes AS FLOAT)) - AVG(f.sla_target_minutes), 1) 
	AS avg_deviation_mins,
	SUM(CASE WHEN f.sla_breached = 1 THEN 1 ELSE 0 END) AS sla_breaches,
	ROUND(SUM(CASE WHEN f.sla_breached = 1 THEN 1.0 ELSE 0 END) /
	NULLIF(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1 ELSE 0 END), 0) * 100, 2)
	AS sla_breach_rate_pct
FROM
	fact_deliveries AS f
JOIN 
	dim_zone AS z
	ON f.zone_id = z.zone_id
GROUP BY z.zone_type
ORDER BY z.zone_type;


-- 4.4 Second attempt recovery rate by zone

SELECT
	z.zone_name,
	z.congestion_level,
	SUM(CASE WHEN f.attempt_number = 2 THEN 1 ELSE 0 END) AS second_attempts,
	SUM(CASE WHEN f.attempt_number = 2 AND f.delivery_status = 'Delivered' THEN 1 ELSE 0 END) AS recovered,
	ROUND(SUM(CASE WHEN f.attempt_number = 2 AND f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END)
	/ NULLIF(SUM(CASE WHEN f.attempt_number = 2 THEN 1 ELSE 0 END), 0) * 100, 2) AS recovery_rate_pct
FROM 
	fact_deliveries AS f
JOIN
	dim_zone AS z
	ON f.zone_id = z.zone_id
GROUP BY z.zone_name, z.congestion_level
ORDER BY recovery_rate_pct ASC;