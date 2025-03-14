-- =================================================================================================
-- Stored Procedure: sliver.validate_household_power_consumption
-- Purpose: Perform data quality checks on the sliver.household_power_consumption table.
-- Author: Junior Data Engineer
-- Date: 2025-03-14
-- Version: 1.0
-- =================================================================================================
CREATE OR ALTER PROCEDURE sliver.validate_household_power_consumption
AS
BEGIN
    -- =============================================================================================
    -- Section 1: NULL Check for date_time
    -- Purpose: Ensure the date_time column does not contain NULL values.
    -- =============================================================================================
    IF EXISTS (SELECT 1 FROM sliver.household_power_consumption WHERE date_time IS NULL)
    BEGIN
        RAISERROR('Data quality issue: NULL date_time found in sliver.household_power_consumption.', 16, 1);
        RETURN; -- Stop execution if this check fails
    END;

    -- =============================================================================================
    -- Section 2: NULL and Invalid Characters Check for global_active_power
    -- Purpose: Ensure global_active_power does not contain NULL values or invalid characters (?).
    -- =============================================================================================
    IF EXISTS(
        SELECT * FROM Sliver.household_power_consumption
        WHERE global_active_power IS NULL OR global_active_power LIKE '%?'
    )
    BEGIN 
        RAISERROR('Data quality issue: NULL values or invalid characters (?) found in global_active_power.', 16, 1);
        RETURN; -- Stop execution if this check fails
    END;

    -- =============================================================================================
    -- Section 3: Duplicate date_time Check
    -- Purpose: Ensure there are no duplicate date_time values.
    -- =============================================================================================
    IF EXISTS(
        SELECT date_time
        FROM Sliver.household_power_consumption
        GROUP BY date_time
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR('Data quality issue: Duplicate date_time values found in sliver.household_power_consumption.', 16, 1);
        RETURN; -- Stop execution if this check fails
    END;

    -- =============================================================================================
    -- Section 4: Start and End Date Check (Dynamic Date Range)
    -- Purpose: Ensure all date_time values fall within the valid range from the source data.
    -- =============================================================================================
    DECLARE @min_valid_date DATETIME2(0);
    DECLARE @max_valid_date DATETIME2(0);

    -- Calculate the minimum and maximum valid dates from the source data
    SELECT
        @min_valid_date = MIN(TRY_CONVERT(DATETIME2(0), CONVERT(VARCHAR, TRY_CONVERT(DATE, [Date], 103), 120) + ' ' + CONVERT(VARCHAR, [Time], 108))),
        @max_valid_date = MAX(TRY_CONVERT(DATETIME2(0), CONVERT(VARCHAR, TRY_CONVERT(DATE, [Date], 103), 120) + ' ' + CONVERT(VARCHAR, [Time], 108)))
    FROM Bronze.household_power_consumption;

    -- Check for out-of-band dates in the Silver table
    IF EXISTS (
        SELECT date_time
        FROM Sliver.household_power_consumption
        WHERE date_time NOT BETWEEN @min_valid_date AND @max_valid_date
    )
    BEGIN
        RAISERROR('Data quality issue: Out-of-band date found in the date_time column.', 16, 1);
        RETURN; -- Stop execution if this check fails
    END;

    -- =============================================================================================
    -- Section 5: Script Completion
    -- Purpose: Notify the user that all data quality checks passed successfully.
    -- =============================================================================================
    PRINT 'All data quality checks passed successfully.';
END;


EXEC sliver.validate_household_power_consumption