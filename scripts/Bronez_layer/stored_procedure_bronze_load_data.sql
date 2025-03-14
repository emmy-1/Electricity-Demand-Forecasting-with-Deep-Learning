-- ================================================================================================================================
-- Stored Procedure: bronze.load_data
-- Purpose: 1. The bronze.load_data procedure is designed to:
--          2. Load data from a text file (@file_path) into the bronze.household_power_consumption table.
--          3. Handle errors during the data loading process and log them using the bronze.log_error procedure.
--          4. Measure and report the time taken to load the data.

-- Procedure Overview: 1. Checks if the table exists: If the bronze.household_power_consumption table exists, it drops the table.
--                     2. Creates the table: Creates a new bronze.household_power_consumption table with the required schema.
--                     3. Loads data: Uses BULK INSERT to load data from the specified text file into the table.
--                     4. Logs errors: If any errors occur during the process, they are logged using the bronze.log_error procedure.
--                     5. Reports load time: Measures and prints the time taken to load the data.

-- Key Features
-- Parameterized the file path: You can enter the path of a text file, and the script will run. However, ensure that you define the correct table.
-- Error Handling:Errors are logged using the bronze.log_error procedure, ensuring that issues are tracked and can be reviewed later.
-- Performance Measurement:The procedure measures and reports the time taken to load the data, providing insights into performance.
-- Idempotent Design:The procedure can be run multiple times without causing issues, as it drops and recreates the table if it already exists.

-- Example Usage
-- To execute the procedure, run the following command:
-- EXECUTE Bronze.load_data @file_path = 'C:\path\to\file.txt';

-- Example Output 
-- When the procedure runs, the PRINT statements and comments will help stakeholders understand the flow of execution:
-- ============================================================
-- CHECKING IF bronze.household_power_consumption TABLE EXISTS?
-- ============================================================
-- ============================================================
-- DROPPING TABLE...
-- ============================================================
-- ============================================================
-- CREATING A NEW TABLE CALLED bronze.household_power_consumption
-- ============================================================
-- ============================================================
-- TRUNCATING AND INSERTING TXT FILE FROM {USER DEFINED PATH}
-- ============================================================
-- >>>>>LOAD TIME: 5 seconds

-- Dependencies
-- 1. bronze.log_error Procedure: This procedure must exist in the bronze schema to log errors.
-- 2. Text File: The file specified in @file_path must exist and be properly formatted.

-- Error Handling
-- If an error occurs during the data loading process:
-- 1. The error details are logged using the bronze.log_error procedure.
-- 2. The error is re-thrown to stop further execution.
-- 3. The error details can be reviewed in the bronze.error_logs table.

-- Permissions
-- The user executing the procedure must have the following permissions:
-- 1. CREATE TABLE and DROP TABLE permissions in the bronze schema.
-- 2. BULK INSERT permissions to load data from the specified file path.
-- 3. EXECUTE permission on the bronze.log_error procedure.

-- =================================================================================================================================

-- Code Breakdown
-- =================================================================================================================================

CREATE OR ALTER PROCEDURE bronze.load_data 
    @file_path NVARCHAR(MAX) -- Parameter for the file path
AS
BEGIN
    -- Declare variables to measure the start and end time of the data load process
    DECLARE @start_time DATETIME, @end_time DATETIME;

    -- Declare a variable to hold the dynamic SQL statement
    DECLARE @sql NVARCHAR(MAX);

    -- Begin the main logic in a TRY block to handle errors gracefully
    BEGIN TRY
        -- ========================================================================================
        -- Step 1: Check if the table exists. If it doesn't, create it.
        -- ========================================================================================
        PRINT '=============================================================================';
        PRINT 'CHECKING IF bronze.household_power_consumption TABLE EXISTS? Creates if it doesn''t';
        PRINT '=============================================================================';

        -- Check if the table exists in the bronze schema
        IF OBJECT_ID('bronze.household_power_consumption', 'U') IS NULL
        BEGIN
            -- Create the table with the specified schema        
            CREATE TABLE bronze.household_power_consumption(
                [Date] NVARCHAR(10),                       
                [Time] TIME,                               
                Global_active_power NVARCHAR(10) NULL,     
                Global_reactive_power NVARCHAR(10) NULL,   
                Voltage NVARCHAR(10) NULL,                 
                Global_intensity NVARCHAR(10) NULL,        
                Sub_metering_1 NVARCHAR(10) NULL,          
                Sub_metering_2 NVARCHAR(10),               
                Sub_metering_3 NVARCHAR(10) NULL           
            );
        END;

        -- ====================================================================================
        -- Step 2: Truncate the table to clear existing data
        -- ====================================================================================
        PRINT '=============================================================================';
        PRINT 'TRUNCATING TABLE...';
        PRINT '=============================================================================';

        TRUNCATE TABLE bronze.household_power_consumption;

        -- ====================================================================================
        -- Step 3: Load data from the text file into the table using BULK INSERT
        -- ====================================================================================
        PRINT '=============================================================================';
        PRINT 'LOADING DATA FROM ' + @file_path;
        PRINT '=============================================================================';

        -- Record the start time of the data load process
        SET @start_time = GETDATE();

        -- Construct the dynamic SQL statement for BULK INSERT
        SET @sql = '
        BULK INSERT bronze.household_power_consumption
        FROM ''' + @file_path + '''
        WITH(
            FIRSTROW = 2,            
            FIELDTERMINATOR = '';'', 
            TABLOCK                 
        );';

        -- Execute the dynamic SQL statement
        EXEC sp_executesql @sql;

        -- Record the end time of the data load process
        SET @end_time = GETDATE();

        -- Calculate and print the total time taken to load the data
        PRINT '>>>>>LOAD TIME: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    END TRY
    -- =============================================================================
    -- Step 4: Handle errors in the CATCH block
    -- =============================================================================
    BEGIN CATCH
        -- Log the error using the bronze.log_error procedure
        EXECUTE log_error @schema_name = 'bronze', @table_name = 'error_logs';
        -- Re-throw the error to stop further execution
        THROW;
    END CATCH;
END;

EXECUTE bronze.load_data 
    @file_path = 'C:\Users\richard\Downloads\individual+household+electric+power+consumption\household_power_consumption.txt'
