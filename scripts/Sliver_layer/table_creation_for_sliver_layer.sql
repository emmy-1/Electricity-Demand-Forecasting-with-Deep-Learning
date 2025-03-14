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