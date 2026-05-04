-- LAGOSLINK EXPRESS LAST-MILE DELIVERY PERFORMANCE ANALYSIS
-- Database: LagosLastMileDB
-- Author: Abdulsamad Kudehinbu Mobolaji


-- SECTION 2: DATA VALIDATION

/*
Before writing a single analytical query, it's worth taking a step back to verify that the data is imported correctly.
*/


-- 2.1 Row counts across all tables
/* 
Expected: 
	fact_deliveries = 8000 rows
	dim_courier = 40 rows
	dim_zone = 12 rows
	dim_date = 731 rows
	dim_failure_reason = 8 rows
*/

SELECT 
	'fact_deliveries' AS table_name,
	COUNT(*) AS row_count
FROM 
	fact_deliveries
UNION ALL

SELECT 
	'dim_courier',
	COUNT(*) 
FROM 
	dim_courier
UNION ALL

SELECT 
	'dim_zone',
	COUNT(*) 
FROM 
	dim_zone
UNION ALL

SELECT 
	'dim_date',
	COUNT(*) 
FROM 
	dim_date
UNION ALL

SELECT 
	'dim_failure_reason',
	COUNT(*) 
FROM 
	dim_failure_reason;

-- Row count matches expected counts, all rows were successfully imported

-- 2.2 Null check on critical fact table columns
/*
The failure_reason_id is intentionally nullable -- successful deliveries won't have one. 
*/

SELECT
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
	SUM(CASE WHEN courier_id IS NULL THEN 1 ELSE 0 END) AS null_courier_id,
	SUM(CASE WHEN zone_id IS NULL THEN 1 ELSE 0 END) AS null_zone_id,
	SUM(CASE WHEN date_id IS NULL THEN 1 ELSE 0 END) AS null_date_id,
	SUM(CASE WHEN delivery_status IS NULL THEN 1 ELSE 0 END) AS null_delivery_status,
	SUM(CASE WHEN actual_time_minutes IS NULL THEN 1 ELSE 0 END) AS null_actual_time_minutes,
	SUM(CASE WHEN distance_km IS NULL THEN 1 ELSE 0 END) AS null_distance_km
FROM 
	fact_deliveries;
-- All columns checked have zero(0) null values

-- 2.3 Delivey status distribution
/*
Verifying that the only values present are 'Delivered' and 'Failed'.
*/

SELECT
	delivery_status,
	COUNT(*) AS total_orders,
	ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM 
	fact_deliveries
GROUP BY 
	delivery_status;


-- 2.4 Date range confirmation
/*
Confirming the data spans the full two-year window (Jan 2024 - Dec 2025) 
and that there are no unexpected gaps in active delivery days
*/

SELECT
	MIN(delivery_date) AS earliest_date,
	MAX(delivery_date) AS latest_date,
	COUNT(DISTINCT delivery_date) AS active_delivery_days
FROM
	fact_deliveries


-- 2.5 Orphan Check -- referential integrity verification
/*
Even with the foreign keys in place, it's good practice to confirm
there are no fact rows that can't be joined to their dimension.  
*/

-- Zones 
SELECT 
	COUNT(*) AS unmatched_zones 
FROM 
	fact_deliveries AS f
LEFT JOIN 
	dim_zone AS z 
ON f.zone_id = z.zone_id
WHERE
	z.zone_id IS NULL;
--unmatched zones returned zero

-- Couriers
SELECT 
	COUNT(*) AS unmatched_couriers
FROM
	fact_deliveries AS f
LEFT JOIN
	dim_courier AS c
ON f.courier_id = c.courier_id
WHERE 
c.courier_id IS NULL;
--unmatched couriers returned zero

-- Dates
SELECT 
	COUNT(*) AS unmatched_dates
FROM
	fact_deliveries AS f
LEFT JOIN
	dim_date AS d
ON f.date_id = d.date_id
WHERE 
d.date_id IS NULL;
--unmatched dates returned zero

-- Failure reasons (excluding NULLs -- those are expected)
SELECT
	COUNT(*) AS unmatched_failure_reasons
FROM
	fact_deliveries AS f
LEFT JOIN
	dim_failure_reason AS fr
ON f.failure_reason_id = fr.failure_reason_id
WHERE
	f.failure_reason_id IS NOT NULL
	AND fr.failure_reason_id IS NULL;
-- unmatched failure reason returned zero
