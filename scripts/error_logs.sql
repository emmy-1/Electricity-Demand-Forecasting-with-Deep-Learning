-- ================================================================================================================================
-- Stored Procedure: log_error
-- Purpose: 
-- Logs errors that occur during the execution of any stored procedure or SQL script. Captures detailed error information, including
-- the error number, severity, state, procedure name, line number, and error message. Stores the error details in a specified
-- schema and table for later review and analysis.

-- Key Features:
-- 1. **Reusable Across Layers**: Can log errors to any schema and table (e.g., Bronze, Silver, Gold).
-- 2. **Dynamic Table Creation**: Creates the error log table if it does not already exist.
-- 3. **Detailed Error Logging**: Captures error number, severity, state, procedure name, line number, and error message.
-- 4. **Automatic Timestamping**: Logs the timestamp of the error automatically using the DEFAULT GETDATE() function.
-- ================================================================================================================================

-- Create or alter the procedure
CREATE OR ALTER PROCEDURE log_error
    @schema_name NVARCHAR(128),   -- Schema name (e.g., 'bronze', 'silver', 'gold')
    @table_name NVARCHAR(128)     -- Table name (e.g., 'error_logs')
AS
BEGIN TRY
    -- ============================================================================================================================
    -- Dynamic Table Creation
    -- Purpose: Creates the error log table if it does not already exist in the specified schema.
    -- ============================================================================================================================
    DECLARE @full_table_name NVARCHAR(256) = QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name);

    IF OBJECT_ID(@full_table_name, 'U') IS NULL
    BEGIN
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = '
        CREATE TABLE ' + @full_table_name + ' (
            log_id INT IDENTITY(1,1) PRIMARY KEY,       -- Unique identifier for each log entry (auto-incremented)
            error_number INT,                           -- Unique identifier for the error
            error_severity INT,                         -- Severity level of the error
            error_state INT,                            -- State of the error
            error_procedure NVARCHAR(128),              -- Name of the procedure where the error occurred
            error_line INT,                             -- Line number in the procedure where the error occurred
            error_message NVARCHAR(MAX),                -- Error message
            log_timestamp DATETIME DEFAULT GETDATE()    -- Timestamp when the error was logged (defaults to current date and time)
        );';
        EXEC sp_executesql @sql;
    END;

    -- ============================================================================================================================
    -- Insert Error Details
    -- Purpose: Captures and logs error details into the specified schema and table.
    -- ============================================================================================================================
    DECLARE @insert_sql NVARCHAR(MAX);
    SET @insert_sql = '
    INSERT INTO ' + @full_table_name + ' (
        error_number,
        error_severity,
        error_state,
        error_procedure,
        error_line,
        error_message
    )
    SELECT
        ERROR_NUMBER(),     -- Unique identifier for the error
        ERROR_SEVERITY(),   -- Severity level of the error
        ERROR_STATE(),      -- State of the error
        ERROR_PROCEDURE(),  -- Name of the procedure where the error occurred
        ERROR_LINE(),       -- Line number in the procedure where the error occurred
        ERROR_MESSAGE()     -- Error message
    ';
    EXEC sp_executesql @insert_sql;
END TRY
BEGIN CATCH
    -- ============================================================================================================================
    -- Error Handling
    -- Purpose: If an error occurs during the execution of the procedure, it captures and returns the error details.
    -- ============================================================================================================================
    SELECT
        ERROR_NUMBER() AS ErrorNumber,     -- Unique identifier for the error
        ERROR_SEVERITY() AS ErrorSeverity, -- Severity level of the error
        ERROR_STATE() AS ErrorState,       -- State of the error
        ERROR_PROCEDURE() AS ErrorProcedure, -- Name of the procedure where the error occurred
        ERROR_LINE() AS ErrorLine,         -- Line number in the procedure where the error occurred
        ERROR_MESSAGE() AS ErrorMessage    -- Error message
END CATCH;