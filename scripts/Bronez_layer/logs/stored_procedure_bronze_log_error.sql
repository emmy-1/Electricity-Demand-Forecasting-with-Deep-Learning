-- ================================================================================================================================
-- Stored Procedure: bronze.log_error
-- Purpose: 
-- 1. Logs errors that occur during the execution of any stored procedure or SQL script.
-- 2. Captures detailed error information, including the error number, severity, state, procedure, line number, and message.
-- 3. Stores the error details in the Bronze.error_logs table for later review and analysis.

-- Procedure Overview:
-- 1. Captures error information using SQL Server's built-in error functions and inserts it into the Bronze.error_logs table.
-- 2. The CREATE OR ALTER statement ensures the procedure is updated if it already exists, avoiding the need to drop it manually.

-- Key Features:
-- 1. Captures detailed error information for debugging and analysis.
-- 2. Stores error details in the Bronze.error_logs table.
-- 3. Idempotent design: The CREATE OR ALTER statement ensures the procedure is always up-to-date.

-- Example Execution:
-- If an error occurs in any stored procedure or script, the bronze.log_error procedure will log the error details to the Bronze.error_logs table.

-- Dependencies:
-- 1. Bronze.error_logs Table: The table must exist with the following schema:see Bronze_error_logs table schema
-- 2. Permissions: The user executing the procedure must have INSERT permissions on the Bronze.error_logs table.
-- ================================================================================================================================

-- Code Breakdown
-- =================================================================================================================================
-- Create or alter the procedure
CREATE OR ALTER PROCEDURE bronze.log_error AS
    BEGIN
        -- Insert error details into the Bronze.error_logs table
        INSERT INTO Bronze.error_logs
        (
            error_number,
            error_severity,
            error_state,
            error_procedure,
            error_line,
            error_message
        )
        SELECT
            ERROR_NUMBER(),     --Unique identifier for the error
            ERROR_SEVERITY(),   -- Severity level of the error
            ERROR_STATE(),      -- State of the error
            ERROR_PROCEDURE(),  -- Name of the procedure where the error occurred
            ERROR_LINE(),       -- Line number in the procedure where the error occurred
            ERROR_MESSAGE()     -- Error message
    END;
