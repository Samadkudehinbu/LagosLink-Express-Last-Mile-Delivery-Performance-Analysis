-- LAGOSLINK EXPRESS LAST-MILE DELIVERY PERFORMANCE ANALYSIS
-- Database: LagosLastMileDB
-- Author: Abdulsamad Kudehinbu Mobolaji


-- SECTION 5: COURIER PERFORMANCE ANALYSIS
/*
Zones set the operating environment, but couriers determine the outcome. This section 
evaluates individual and grouped courier performance across success rates, delivery speed, 
SLA compliance, and experience level.
*/

-- 5.1 Courier performance scorecard

WITH courier_stats AS (
	SELECT
		c.courier_code,
		c.experience_level,
		c.vehicle_type,
		c.avg_rating,
		COUNT(f.order_id) AS total_deliveries,
		ROUND(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END)/
		COUNT(f.order_id) * 100, 2) AS success_rate_pct,
		ROUND(AVG(CAST(f.actual_time_minutes AS FLOAT)), 1) AS avg_delivery_mins,
		SUM(CASE WHEN f.sla_breached = 1 THEN 1 ELSE 0 END) AS sla_breaches,
		SUM(CASE WHEN f.attempt_number =2 THEN 1 ELSE 0 END) AS  second_attempts
	FROM 
		fact_deliveries AS f
	JOIN 
		dim_courier AS c
		ON f.courier_id = c.courier_id
	GROUP BY 
		c.courier_code, c.experience_level, c.vehicle_type, c.avg_rating
)
SELECT 
	courier_code,
	experience_level,
	vehicle_type,
	avg_rating,
	total_deliveries,
	success_rate_pct,
	avg_delivery_mins,
	sla_breaches,
	second_attempts,
	RANK() OVER (ORDER BY success_rate_pct DESC) AS performance_rank,
	ROUND(PERCENT_RANK() OVER (ORDER BY success_rate_pct) * 100, 1) AS success_percentile
FROM 
	courier_stats
ORDER BY 
	performance_rank


-- 5.2 Performance breakdown by experience Levl

SELECT
	c.experience_level,
	COUNT(DISTINCT f.courier_id) AS courier_count,
	COUNT(f.order_id) AS total_orders,
	ROUND(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END)/
	COUNT(f.order_id) * 100, 2) AS success_rate_pct,
	ROUND(AVG(CAST(f.actual_time_minutes AS FLOAT)), 1) AS avg_delivery_mins,
	SUM(CASE WHEN f.sla_breached = 1 THEN 1 ELSE 0 END) AS total_sla_breaches,
	ROUND(SUM(CASE WHEN f.sla_breached = 1 THEN 1.0 ELSE 0 END)
	/ NULLIF(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1 ELSE 0 END), 0) * 100, 2) 
	AS sla_breach_rate_pct,
	SUM(CASE WHEN f.attempt_number = 2 THEN 1 ELSE 0 END) AS second_attempts
FROM 
	fact_deliveries AS f
JOIN 
	dim_courier AS c
	ON f.courier_id = c.courier_id
GROUP BY c.experience_level
ORDER BY success_rate_pct DESC;


-- 5.3 Top 10 and Bottom 10 couriers by success rate
/*
A minumum delivery threshold of 50 orders is applies to ensure the ranking reflects consistent 
performance rather than a small sample size
*/

WITH courier_ranked AS (
	SELECT
		c.courier_code,
		c.experience_level,
		c.vehicle_type,
		COUNT(f.order_id) AS total_deliveries,
		ROUND(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END)/
		COUNT(f.order_id) * 100, 2) AS success_rate_pct,
		RANK() OVER (ORDER BY SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END)/
		COUNT(f.order_id) DESC) AS rnk
	FROM
		fact_deliveries AS f
	JOIN	
		dim_courier AS c
		ON f.courier_id = c.courier_id
	GROUP BY 
		c.courier_code, c.experience_level, c.vehicle_type
	HAVING COUNT(f.order_id) >= 50
)
SELECT
	courier_code,
	experience_level,
	vehicle_type,
	total_deliveries,
	success_rate_pct,
	rnk,
	'Top 10' AS category
FROM 
	courier_ranked
WHERE 
	rnk <= 10
UNION ALL 
SELECT
	courier_code,
	experience_level,
	vehicle_type,
	total_deliveries,
	success_rate_pct,
	rnk,
	'Bottom 10'
FROM 
	courier_ranked
WHERE 
	rnk > (SELECT MAX(rnk) -10 FROM courier_ranked)
ORDER BY
	category,
	rnk;

-- 5.4 Courier performance consistency using standard deviation
/*
A high success rate average means little if performance swings wildly from month to month.
This query measuers delivery time consistency per courier. A lower standard deviation indicates 
a more reliable and predictable courier regardless of conditions.
*/

SELECT
	c.courier_code,
	c.experience_level,
	COUNT(f.order_id) AS total_deliveries,
	ROUND(AVG(CAST(f.actual_time_minutes AS FLOAT)), 1) AS avg_delivery_mins,
	ROUND(STDEV(CAST(f.actual_time_minutes AS FLOAT)), 1) AS stdev_delivery_mins,
	ROUND(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END)/
	COUNT(f.order_id) * 100, 2) AS success_rate_pct
FROM 
	fact_deliveries AS f
JOIN 
	dim_courier AS c 
	ON f.courier_id = c.courier_id
GROUP BY 
	c.courier_code, c.experience_level
HAVING COUNT(f.order_id) >= 50
ORDER BY stdev_delivery_mins ASC;