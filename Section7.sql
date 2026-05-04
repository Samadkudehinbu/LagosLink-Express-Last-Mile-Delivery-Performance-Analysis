-- LAGOSLINK EXPRESS LAST-MILE DELIVERY PERFORMANCE ANALYSIS
-- Database: LagosLastMileDB
-- Author: Abdulsamad Kudehinbu Mobolaji


-- SECTION 7: FAILURE REASON ANALYSIS
/*
This section breaks down the 884 failed deliveries by root cause, geography, and courier experience; 
providibg LagosLink Express with a clear picture of whether failures are driven by customer 
behaviour, operational gaps, or external conditions.
*/

-- 7.1 Overall failure reason breakdown
SELECT
	fr.reason_description,
	fr.category,
	COUNT(f.order_id) AS total_failures,
	ROUND(COUNT(f.order_id) * 100.0/SUM(COUNT(f.order_id)) OVER(), 2) AS pct_of_total_failures
FROM 
	fact_deliveries AS f
JOIN
	dim_failure_reason AS fr
	ON f.failure_reason_id = fr.failure_reason_id
WHERE
	f.delivery_status = 'Failed'
GROUP BY
	fr.reason_description, fr.category
ORDER BY 
	total_failures DESC;


-- 7.2 Failure reason breakdown by category
SELECT
	fr.category,
	COUNT(f.order_id) AS total_failures,
	ROUND(COUNT(f.order_id) * 100.0 / SUM(COUNT(f.order_id)) OVER(), 2) AS pct_of_total_failures
FROM
	fact_deliveries AS f
JOIN
	dim_failure_reason AS fr
	ON f.failure_reason_id = fr.failure_reason_id
WHERE
	f.delivery_status = 'Failed'
GROUP BY
	fr.category
ORDER BY 
	total_failures DESC;


-- 7.3 Top failure reason per zone

WITH zone_failures AS (
	SELECT
		z.zone_name,
		fr.reason_description,
		fr.category,
		COUNT(f.order_id) AS failure_count,
		RANK() OVER (PARTITION BY z.zone_name ORDER BY COUNT(f.order_id) DESC) AS rnk
	FROM
		fact_deliveries AS f
	JOIN
		dim_zone AS z
		ON f.zone_id = z.zone_id
	JOIN
		dim_failure_reason AS fr
		ON f.failure_reason_id = fr.failure_reason_id
	WHERE
		f.delivery_status = 'Failed'
	GROUP BY
		z.zone_name, fr.reason_description, fr.category
)
SELECT
	zone_name,
	reason_description AS top_failure_reason,
	category,
	failure_count
FROM 
	zone_failures
WHERE 
	rnk = 1
ORDER BY
	failure_count DESC;


-- 7.4 Failure reasons by courier experience level

SELECT
	c.experience_level,
	fr.reason_description,
	fr.category,
	COUNT(f.order_id) AS failure_count,
	ROUND(COUNT(f.order_id) * 100.0 / SUM(COUNT(f.order_id)) OVER (PARTITION BY c.experience_level), 2)
	AS pct_within_experience
FROM 
	fact_deliveries AS f
JOIN
	dim_courier AS c
	ON f.courier_id = c.courier_id
JOIN
	dim_failure_reason AS fr
	ON f.failure_reason_id = fr.failure_reason_id
WHERE 
	f.delivery_status = 'Failed'
GROUP BY 
	c.experience_level, fr.reason_description, fr.category
ORDER BY
	c.experience_level, failure_count;