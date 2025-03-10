-- ================================================================================================================================
-- Stored Procedure: bronze.log_error
-- Purpose: 1. Logs errors that occur during the execution of the bronze.load_data procedure.
--          2. Capture detailed error information, including the error number, severity, state, procedure, line number, and message.
--          3. Store the error details in the Bronze.error_logs table for later review and analysis.

-- Procedure Overview: 1. Captures error information using SQL Server's built-in error functions and inserts it into the Bronze.error_logs table.
--                     2. The CREATE OR ALTER statement ensures the procedure is updated if it already exists, avoiding the need to drop it manually.

-- Example Execution:  If an error occurs in stored_procedure_bronze_load_data, the bronze.log_error procedure will log the error details to the Bronze.error_logs table.
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
