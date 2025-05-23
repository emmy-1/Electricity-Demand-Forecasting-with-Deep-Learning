-- =================================================================================================
-- Script: Aggregate and Load 15-Minute Interval Data into the Gold Layer
-- Author: Junior Data Engineer
-- Date: 2025-03-14
-- Version: 1.0
-- Description:
-- This script aggregates household power consumption data from the Silver layer into 15-minute intervals
-- and loads it into the Gold layer. It calculates average values for key metrics such as global active power,
-- global reactive power, voltage, and global intensity. The script ensures idempotency by dropping and
-- recreating the target table if it already exists.
-- =================================================================================================

-- =================================================================================================
-- Section 1: Table Creation (Idempotent)
-- Purpose: Creates a table to store aggregated 15-minute interval data in the Gold layer.
--          Ensures idempotency by dropping and recreating the table if it already exists.
-- =================================================================================================
CREATE OR ALTER PROCEDURE gold.fifteen_min_load_data
AS
BEGIN TRY 
    -- Check if the table exists in the Gold schema
    IF OBJECT_ID('Gold.household_power_consumption_at_15_min_interval', 'U') IS NOT NULL
        BEGIN
            -- Drop the table if it exists
            DROP TABLE Gold.household_power_consumption_at_15_min_interval;
        END;

    -- Create a new table to store 15-minute interval data
    CREATE TABLE Gold.household_power_consumption_at_15_min_interval(
        date_time  DATETIME2,                          -- Column to store the start time of the 15-minute interval
        [month] INT,
        [hour] INT,
        day_of_week INT,
        is_weekend INT,
        [15_lag] DECIMAL(10, 6),
        avg_global_active_power DECIMAL(10, 6),        -- Column to store the average global active power (in kW)
        avg_global_reactive_power  DECIMAL(10, 6),     -- Column to store the average global reactive power (in kW)
        avg_voltage  DECIMAL(10, 6),                   -- Column to store the average voltage (in volts)
        avg_global_intensity DECIMAL(10,6),            -- Column to store the average global current intensity (in amperes)
        dwh_create_date DATETIME2(0) DEFAULT GETDATE() -- Column to store the record creation timestamp (defaults to current date/time)
    );

-- =================================================================================================
-- Section 2: Data Aggregation
-- Purpose: Aggregate household power consumption data from the Silver layer into 15-minute intervals.
-- =================================================================================================
    
    -- Create a CTE with the interval aggregates first
    WITH IntervalData AS (
        SELECT
            DATEADD(MINUTE, DATEDIFF(MINUTE, 0, date_time) / 15 * 15, 0) AS interval_start, -- Round the timestamp to the nearest 15-minute interval
            DATEPART(MONTH, date_time) as [month],
            DATEPART(HOUR, date_time) as [hour],
            DATEPART(WEEKDAY, date_time) -1 as day_of_week,
            CASE 
                WHEN DATEPART(WEEKDAY, date_time) IN (1, 7) THEN 1  -- Sunday (1) and Saturday (7)
                ELSE 0 
            END as is_weekend,
            AVG(global_active_power) AS avg_global_active_power,                            -- Calculate the average global active power
            AVG(global_reactive_power) AS avg_global_reactive_power,                        -- Calculate the average global reactive power
            AVG(voltage) AS avg_voltage,                                                    -- Calculate the average voltage
            AVG(global_intensity) AS avg_global_intensity                                   -- Calculate the average global current intensity
        FROM sliver.household_power_consumption                                            -- Source table for the data
        GROUP BY 
            DATEADD(MINUTE, DATEDIFF(MINUTE, 0, date_time) / 15 * 15, 0),
            DATEPART(MONTH, date_time),
            DATEPART(HOUR, date_time),
            DATEPART(WEEKDAY, date_time) -1,
            CASE 
                WHEN DATEPART(WEEKDAY, date_time) IN (1, 7) THEN 1
                ELSE 0 
            END
    )
    
    -- Now apply the LAG function and insert into the final table
    INSERT INTO gold.household_power_consumption_at_15_min_interval(
        date_time,
        [month],
        [hour],
        day_of_week,
        is_weekend,
        [15_lag],
        avg_global_active_power,
        avg_global_reactive_power,
        avg_voltage,
        avg_global_intensity 
    )
    SELECT
        interval_start,
        [month],
        [hour],
        day_of_week,
        is_weekend,
        LAG(avg_global_active_power, 1) OVER (ORDER BY interval_start) as lag_15min,
        avg_global_active_power,
        avg_global_reactive_power,
        avg_voltage,
        avg_global_intensity
    FROM IntervalData
    ORDER BY interval_start;

END TRY
BEGIN CATCH
    -- =================================================================================================
    -- Section 3: Error Handling
    -- Purpose: Log errors and rethrow them to ensure visibility and debugging.
    -- =================================================================================================
    -- Log the error using the 'log_error' procedure
    EXEC log_error @schema_name = 'gold', @table_name = '15_error_logs';
    -- Rethrow the error to halt execution and provide feedback
    THROW;
END CATCH;
-- =================================================================================================
-- Section 4: Execution
-- Purpose: Execute the stored procedure to load the 15-minute interval data into the Gold layer.
-- =================================================================================================
-- Run the stored procedure
EXECUTE gold.fifteen_min_load_data;
