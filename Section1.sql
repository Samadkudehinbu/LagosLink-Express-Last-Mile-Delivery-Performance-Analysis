-- LAGOSLINK EXPRESS LAST-MILE DELIVERY PERFORMANCE ANALYSIS
-- Database: LagosLastMileDB
-- Author: Abdulsamad Kudehinbu Mobolaji


-- SECTION 1: PRIMARY KEYS AND FOREIGN KEYS

/*
Before doing anything analytical, it is important to define how each 
table in the database are related to each other.
Primary keys uniquely identify each row in a table. Foreign keys are how the
fact table points back to the dimension tables.

These are the tables
1. dim_zone
2. dim_courier
3. dim_failure_reason
4. dim_date
5. fact_deliveries -- Fact Table
*/


-- Dimension table primary keys
ALTER TABLE dim_zone
ADD CONSTRAINT PK_dim_zone PRIMARY KEY (zone_id);

ALTER TABLE dim_courier
ADD CONSTRAINT PK_dim_courier PRIMARY KEY (courier_id)

ALTER TABLE dim_failure_reason
ADD CONSTRAINT PK_dim_failure_reason PRIMARY KEY (failure_reason_id)

/* 
date_id is used as the join key accross the schema rather than joining
directly on the date column. This is more performanct at scale and keeps the
fact table lightweight
*/
ALTER TABLE dim_date
ADD CONSTRAINT PK_dim_date PRIMARY KEY (date_id);

-- Fact table primary key
-- Grain: one row per delivery attempt (order_id is unique per attempt)
ALTER TABLE fact_deliveries
ADD CONSTRAINT PK_dim_date_deliveries PRIMARY KEY (order_id);


-- Foreign key constraints on fact_deliveries
/*
These enforce referential integrity -- any zone_id, courier_id, date_id, or
failure_reason_id in the fact table must have a matching record in its respective
dimension table
*/

ALTER TABLE fact_deliveries
ADD CONSTRAINT FK_fact_zone
	FOREIGN KEY (zone_id) REFERENCES dim_zone(zone_id);

ALTER TABLE fact_deliveries
ADD CONSTRAINT FK_fact_courier
	FOREIGN KEY (courier_id) REFERENCES dim_courier(courier_id);

ALTER TABLE fact_deliveries
ADD CONSTRAINT FK_fact_date
	FOREIGN KEY (date_id) REFERENCES dim_date(date_id);

/*
failure_reason_id is nullable -- suceessful deliveries carry no failure reason,
so NULL is a valid and expected value
*/

ALTER TABLE fact_deliveries
ALTER COLUMN failure_reason_id TINYINT NULL;

ALTER TABLE fact_deliveries
ADD CONSTRAINT FK_fact_failure_reason
    FOREIGN KEY (failure_reason_id) 
	REFERENCES dim_failure_reason(failure_reason_id);







