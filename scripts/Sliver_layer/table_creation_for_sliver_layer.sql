-- ================================================================================================================================
-- Table Creation Script: sliver.household_power_consumption
-- Purpose: Creates a table to move data from the bronze.household_power_consumption into the sliver layer(sliver.household_power_consumption).
--          Ensures idempotency by dropping and recreating the table if it already exists.
-- ================================================================================================================================

-- Check if the table exists in the sliver schema
        IF OBJECT_ID('sliver.household_power_consumption', 'U') IS NOT NULL
        BEGIN
            -- Drop the table if it exists
            DROP TABLE sliver.household_power_consumption;
        END;

        -- ====================================================================================
        -- Step 2: Create a new table called sliver.household_power_consumption
        -- ====================================================================================
        PRINT '=============================================================================';   
        PRINT 'CREATING A NEW TABLE CALLED sliver.household_power_consumption';
        PRINT '=============================================================================';

        -- Create the table with the specified schema        
        CREATE TABLE sliver.household_power_consumption(
            [Date] DATETIME2,                           -- Date column (e.g., "16/12/2006")
            [Time] TIME,                                -- Time column (e.g., "17:24:00")
            Global_active_power FLOAT,                  -- Global active power (nullable)
            Global_reactive_power FLOAT,                -- Global reactive power (nullable)   
            Voltage FLOAT,                              -- Voltage (nullable)                 
            Global_intensity FLOAT,                     -- Global intensity (nullable)
            Sub_metering_1 FLOAT,                       -- Sub-metering 1 (nullable)
            Sub_metering_2 FLOAT,                       -- Sub-metering 2 (non-nullable)
            Sub_metering_3 FLOAT,                       -- Sub-metering 3 (nullable)
            dwh_create_date DATETIME2 DEFAULT GETDATE()          
        );