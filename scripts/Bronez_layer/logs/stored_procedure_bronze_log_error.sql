IF OBJECT_ID('bronze.log_error', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE bronze.log_error;
END
GO;

CREATE PROCEDURE bronze.log_error AS
    BEGIN
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
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            ERROR_MESSAGE()
    END;
GO;
