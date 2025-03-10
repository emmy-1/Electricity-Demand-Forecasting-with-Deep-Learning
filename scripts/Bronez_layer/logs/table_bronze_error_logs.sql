-- ================================================================================================================================
-- Table Creation Script: bronze.error_logs
-- Purpose: Creates a table to store detailed error information captured by the bronze.log_error procedure.
--          Ensures idempotency by dropping and recreating the table if it already exists.
-- ================================================================================================================================

-- Drop the table if it already exists
IF OBJECT_ID('bronze.error_logs', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.error_logs;
END;

-- Create the table
CREATE TABLE bronze.error_logs (
    log_id INT IDENTITY(1,1) PRIMARY KEY,       -- Unique identifier for each log entry (auto-incremented)
    error_number INT,                           -- Unique identifier for the error
    error_severity INT,                         -- Severity level of the error
    error_state INT,                            -- State of the error
    error_procedure NVARCHAR(128),              -- Name of the procedure where the error occurred
    error_line INT,                             -- Line number in the procedure where the error occurred
    error_message NVARCHAR(MAX),                -- Error message
    log_timestamp DATETIME DEFAULT GETDATE()    -- Timestamp when the error was logged (defaults to current date and time)
);