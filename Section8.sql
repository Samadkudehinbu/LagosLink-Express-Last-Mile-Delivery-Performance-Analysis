-- LAGOSLINK EXPRESS LAST-MILE DELIVERY PERFORMANCE ANALYSIS
-- Database: LagosLastMileDB
-- Author: Abdulsamad Kudehinbu Mobolaji


-- SECTION 8: TIME-SERIES AND TREND ANALYSIS
/*
With two full years of data, this section examines how LagosLink Experess's delivery performance 
has evolved over time - monthly, quarterly, and year-over-year and identifies seasonal patterns 
that should inform operational planning going forward
*/

-- 8.1 Monthly delivery volume and success rate

SELECT
	d.year,
	d.month_number,
	d.month_name,
	COUNT(f.order_id) AS total_orders,
	SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered,
	SUM(CASE WHEN f.delivery_status = 'Failed' THEN 1 ELSE 0 END) AS failed,
	ROUND(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END) /
	COUNT(f.order_id) * 100, 2) AS success_rate_pct
FROM 
	fact_deliveries AS f
JOIN 
	dim_date AS d
	ON f.date_id = d.date_id
GROUP BY 
	d.year, d.month_number, d.month_name
ORDER BY
	d.year, d.month_number;


-- 8.2 Year-over-Year comparison (2024 vs 2025)

WITH yearly AS (
	SELECT
		d.year,
		d.month_number,
		d.month_name,
		COUNT(f.order_id) AS total_orders,
		ROUND(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END) /
		COUNT(f.order_id) * 100, 2) AS success_rate_pct
	FROM 
		fact_deliveries AS f
	JOIN
		dim_date AS d
		ON f.date_id = d.date_id
	GROUP BY
		d.year, d.month_number, d.month_name
)
SELECT
	y2024.month_name,
	y2024.month_number,
	y2024.total_orders AS orders_2024,
	y2025.total_orders AS orders_2025,
	y2025.total_orders - y2024.total_orders AS volume_change,
	y2024.success_rate_pct AS success_rate_2024,
	y2025.success_rate_pct AS success_rate_2025,
	ROUND(y2025.success_rate_pct - y2024.success_rate_pct, 2) AS success_rate_change
FROM
	yearly AS y2024
JOIN
	yearly AS y2025
	ON y2024.month_number = y2025.month_number
	AND y2024.year = 2024
	AND y2025.year = 2025
ORDER BY 
	y2024.month_number;


-- 8.3 Quarterly performance summary

SELECT
	d.year,
	d.quarter_label,
	COUNT(f.order_id) AS total_orders,
	ROUND(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END) /
	COUNT(f.order_id) * 100, 2) AS success_rate_pct,
	ROUND(AVG(CAST(f.actual_time_minutes AS FLOAT)), 1) AS avg_delivery_mins,
	SUM(CASE WHEN f.sla_breached = 1 THEN 1 ELSE 0 END) AS sla_breaches
FROM 
	fact_deliveries AS f
JOIN 
	dim_date AS d
	ON f.date_id = d.date_id
GROUP BY
	d.year, d.quarter_label, d.quarter
ORDER BY
	d.year, d.quarter;


-- 8.4 Rolling 3-month success rate

WITH monthly AS (
	SELECT
		d.year,
		d.month_number,
		d.month_name,
		COUNT(f.order_id) AS total_orders,
		SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END) AS delivered
	FROM 
		fact_deliveries AS f
	JOIN
		dim_date AS d
		ON f.date_id = d.date_id
	GROUP BY
		d.year, d.month_number, d.month_name
)
SELECT 
	year,
	month_name,
	total_orders,
	ROUND(delivered / total_orders * 100, 2) AS monthly_success_rate_pct,
	ROUND(SUM(delivered) OVER(ORDER BY year, month_number ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) /
	NULLIF(SUM(total_orders) OVER (ORDER BY year, month_number 
	ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0) * 100, 2) AS rolling_3m_success_rate_pct
FROM 
	monthly
ORDER BY
	year, month_number;


-- 8.5 Weekend vs Weekday Performance

SELECT
	CASE WHEN d.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
	COUNT(f.order_id) AS total_orders,
	ROUND(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1.0 ELSE 0 END) /
	COUNT(f.order_id) * 100, 2) AS success_rate_pct,
	ROUND(AVG(CAST(f.actual_time_minutes AS FLOAT)), 1) AS avg_delivery_mins,
	SUM(CASE WHEN f.sla_breached = 1 THEN 1 ELSE 0 END) AS sla_breaches,
	ROUND(SUM(CASE WHEN f.sla_breached = 1 THEN 1.0 ELSE 0 END) /
	NULLIF(SUM(CASE WHEN f.delivery_status = 'Delivered' THEN 1 ELSE 0 END), 0) * 100, 2) 
	AS sla_breach_rate_pct
FROM 
	fact_deliveries AS f
JOIN 
	dim_date AS d
	ON f.date_id = d.date_id
GROUP BY
	d.is_weekend
ORDER BY
	day_type;