-- =================================================================================================
-- Script: Transform and Load Data into the sliver layer
-- Author: Junior Data Engineer
-- Date: 2025-03-14
-- Version: 1.0
-- Description:
-- This script transforms raw household power consumption data from the Bronze layer into a clean,
-- structured, and analysis-ready format for the Silver layer. It ensures data quality by handling
-- missing values, combining date and time into a single column, and replacing NULLs with column
-- averages.
-- =================================================================================================


-- =================================================================================================
-- Section 1: Table Creation (Idempotent)
-- Purpose: Creates a table to move data from the bronze.household_power_consumption into the sliver layer(sliver.household_power_consumption).
--          Ensures idempotency by dropping and recreating the table if it already exists.
-- =================================================================================================
CREATE OR ALTER PROCEDURE sliver.load_data 
    AS
    BEGIN TRY
        -- Check if the table exists in the sliver schema
        IF OBJECT_ID('sliver.household_power_consumption', 'U') IS NOT NULL
        BEGIN
            -- Drop the table if it exists
            DROP TABLE sliver.household_power_consumption;
        END;

        -- Step 2: Create a new table called sliver.household_power_consumption     
        CREATE TABLE sliver.household_power_consumption(
            [date_time] DATETIME2(0),                           -- Date column (e.g., "16/12/2006")
            --[Time] TIME,                                -- Time column (e.g., "17:24:00")
            global_active_power DECIMAL(10, 3),                  -- Global active power (nullable)
            global_reactive_power DECIMAL(10, 3),                -- Global reactive power (nullable)   
            voltage DECIMAL(10, 3),                              -- Voltage (nullable)                 
            global_intensity DECIMAL(10, 3),                     -- Global intensity (nullable)
            kitchen DECIMAL(10, 3),                       -- Sub-metering 1 (nullable)
            laundry_room DECIMAL(10, 3),                       -- Sub-metering 2 (non-nullable)
            other_appliences DECIMAL(10, 3),                       -- Sub-metering 3 (nullable)
            dwh_create_date DATETIME2(0) DEFAULT GETDATE()          
        );


-- =================================================================================================
-- Section 2: Data Transformation
-- Purpose: Clean and transform raw household power consumption data from the Bronze layer.
-- =================================================================================================
        WITH transformation AS (
            SELECT
                -- Combine Date and Time into a single DateTime column
                TRY_CONVERT(DATETIME2(0), CONVERT(VARCHAR, TRY_CONVERT(DATE, [Date], 103), 120) + ' ' + CONVERT(VARCHAR, [Time], 108)) AS [dateTime],
                CASE 
                    WHEN Global_active_power = '?' THEN NULL 
                    ELSE TRY_CAST(Global_active_power AS DECIMAL(10, 3)) 
                END AS global_active_power,
                CASE 
                    WHEN Global_reactive_power = '?' THEN NULL 
                    ELSE TRY_CAST(Global_reactive_power AS DECIMAL(10, 3)) 
                END AS global_reactive_power,
                CASE 
                    WHEN Voltage = '?' THEN NULL 
                    ELSE TRY_CAST(Voltage AS DECIMAL(10, 3)) 
                END AS voltage,
                CASE 
                    WHEN Global_intensity = '?' THEN NULL 
                    ELSE TRY_CAST(Global_intensity AS DECIMAL(10, 3)) 
                END AS global_intensity,
                CASE 
                    WHEN Sub_metering_1 = '?' THEN NULL 
                    ELSE TRY_CAST(Sub_metering_1 AS DECIMAL(10, 3)) 
                END AS kitchen,
                CASE 
                    WHEN Sub_metering_2 = '?' THEN NULL 
                    ELSE TRY_CAST(Sub_metering_2 AS DECIMAL(10, 3)) 
                END AS laundry_room,
                CASE 
                    WHEN Sub_metering_3 = '?' THEN NULL 
                    ELSE TRY_CAST(Sub_metering_3 AS DECIMAL(10, 3)) 
                END AS other_appliences
            FROM Bronze.household_power_consumption
        ),
        column_means AS (
            SELECT
                AVG(global_active_power) AS mean_global_active_power,
                AVG(global_reactive_power) AS mean_global_reactive_power,
                AVG(voltage) AS mean_voltage,
                AVG(global_intensity) AS mean_global_intensity,
                AVG(kitchen) AS mean_metring_kitchen,
                AVG(laundry_room) AS mean_laundry_room,
                AVG(other_appliences) AS mean_other_appliences
            FROM transformation
        )


-- =================================================================================================
-- Section 3: Data Loading
-- Purpose: Insert the transformed data into the Silver layer.
-- =================================================================================================
        -- Insert the transformed data into the Silver table
        INSERT INTO sliver.household_power_consumption (
            [date_time],
            global_active_power,
            global_reactive_power,
            voltage,
            global_intensity,
            kitchen,
            laundry_room,
            other_appliences
        )
        SELECT
            t.dateTime, -- Extract Date part
            ROUND(COALESCE(t.global_active_power, cm.mean_global_active_power), 3) AS global_active_power,
            ROUND(COALESCE(t.global_reactive_power, cm.mean_global_reactive_power), 3) AS global_reactive_power,
            ROUND(COALESCE(t.voltage, cm.mean_voltage), 3) AS voltage,
            ROUND(COALESCE(t.global_intensity, cm.mean_global_intensity), 3) AS global_intensity,
            ROUND(COALESCE(t.kitchen, cm.mean_metring_kitchen), 3) AS kitchen,
            ROUND(COALESCE(t.laundry_room, cm.mean_laundry_room), 3) AS laundry_room,
            ROUND(COALESCE(t.other_appliences, cm.mean_other_appliences), 3) AS other_appliences
        FROM transformation t
        CROSS JOIN column_means cm;
    END TRY
    BEGIN CATCH
        EXEC log_error @schema_name = 'silver', @table_name = 'error_logs';
        THROW;
    END CATCH

-- Run stored procedure 
EXECUTE sliver.load_data
