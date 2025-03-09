IF OBJECT_ID('bronze.error_logs', 'U') IS NOT NULL
    BEGIN
        DROP TABLE bronze.error_logs 
    END;

    BEGIN
        CREATE TABLE bronze.error_logs (
            log_id INT IDENTITY(1,1) PRIMARY KEY,
            error_number INT,
            error_severity INT,
            error_state INT,
            error_procedure NVARCHAR(128),
            error_line INT,
            error_message NVARCHAR(MAX),
            log_timestamp DATETIME DEFAULT GETDATE()

        );
END;
