-- LAGOSLINK EXPRESS LAST-MILE DELIVERY PERFORMANCE ANALYSIS
-- Database: LagosLastMileDB
-- Author: Abdulsamad Kudehinbu Mobolaji


-- SECTION 6: SLA BREACH ANALYSIS
/*
With a 35.86% SLA breach rate flagged in Section 3, this section digs into where, when, and 
why those breaches are occuring, giving LagosLink Express the granularity needed to act on 
the problem rather than just observe it
*/

-- 6.1 SLA breach rate by zone and congestion level

SELECT
	z.zone_name,
	z.zone_type,
	z.congestion_level,
	SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
	SUM(CASE WHEN f.sla_breached = 1 THEN 1 ELSE 0 END) AS sla_breaches,
	ROUND(SUM(CASE WHEN f.sla_breached = 1 THEN 1.0 ELSE 0 END) /
	NULLIF(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1 ELSE 0 END), 0) * 100, 2) 
	AS sla_breach_rate_pct
FROM 
	fact_deliveries AS f
JOIN 
	dim_zone AS z
	ON f.zone_id = z.zone_id
GROUP BY 
	z.zone_name, z.zone_type, z.congestion_level
ORDER BY sla_breach_rate_pct DESC;


-- 6.2 SLA breach rate by hour of day

SELECT
	f.scheduled_hour,
	COUNT(f.order_id) As total_delivered,
	SUM(CASE WHEN f.sla_breached = 1 THEN 1 ELSE 0 END) AS sla_breaches,
	ROUND(SUM(CASE WHEN f.sla_breached = 1 THEN 1.0 ELSE 0 END) /
	NULLIF(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1 END), 0) * 100, 2) 
	AS breach_rate_pct
FROM 
	fact_deliveries AS f
WHERE
	f.delivery_status = 'Delivered'
GROUP BY 
	f.scheduled_hour
ORDER BY 
	f.scheduled_hour;


-- 6.3 Average delivery time vs SLA target by zone

SELECT
	z.zone_name,
	z.zone_type,
	AVG(f.sla_target_minutes) AS sla_target_mins,
	ROUND(AVG(CAST(f.actual_time_minutes AS FLOAT)), 1) AS avg_actual_mins,
	ROUND(AVG(CAST(f.actual_time_minutes AS FLOAT)) - AVG(f.sla_target_minutes), 1) 
	AS avg_deviation_mins
FROM
	fact_deliveries AS f
JOIN
	dim_zone AS z
	ON f.zone_id = z.zone_id
WHERE 
	f.delivery_status = 'Delivered'
GROUP BY 
	z.zone_name, z.zone_type
ORDER BY 
	avg_deviation_mins DESC;


--6.4 SLA breach rate by experience level

SELECT
	c.experience_level,
	SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
	SUM(CASE WHEN f.sla_breached = 1 THEN 1 ELSE 0 END) AS sla_breaches,
	ROUND(SUM(CASE WHEN f.sla_breached = 1 THEN 1.0 ELSE 0 END) /
	NULLIF(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1 ELSE 0 END), 0) * 100, 2) 
	AS sla_breach_rate_pct,
	ROUND(AVG(CAST(f.actual_time_minutes AS FLOAT)), 1) AS avg_delivery_mins
FROM 
	fact_deliveries AS f
JOIN
	dim_courier AS c
	ON f.courier_id = c.courier_id
WHERE 
	f.delivery_status = 'Delivered'
GROUP BY
	c.experience_level
ORDER BY 
	sla_breach_rate_pct DESC;