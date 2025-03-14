-- ================================================================================================
-- Sliver Table Transformation
-- ================================================================================================

-- Define the CTEs first
WITH transformation AS (
    SELECT
        -- Combine Date and Time into a single DateTime column
        TRY_CONVERT(DATETIME2(0), CONVERT(VARCHAR, TRY_CONVERT(DATE, [Date], 103), 120) + ' ' + CONVERT(VARCHAR, [Time], 108)) AS [dateTime],
        CASE 
            WHEN Global_active_power = '?' THEN NULL 
            ELSE TRY_CAST(Global_active_power AS DECIMAL(10, 3)) 
        END AS global_active_power,
        CASE 
            WHEN Global_reactive_power = '?' THEN NULL 
            ELSE TRY_CAST(Global_reactive_power AS DECIMAL(10, 3)) 
        END AS global_reactive_power,
        CASE 
            WHEN Voltage = '?' THEN NULL 
            ELSE TRY_CAST(Voltage AS DECIMAL(10, 3)) 
        END AS voltage,
        CASE 
            WHEN Global_intensity = '?' THEN NULL 
            ELSE TRY_CAST(Global_intensity AS DECIMAL(10, 3)) 
        END AS global_intensity,
        CASE 
            WHEN Sub_metering_1 = '?' THEN NULL 
            ELSE TRY_CAST(Sub_metering_1 AS DECIMAL(10, 3)) 
        END AS kitchen,
        CASE 
            WHEN Sub_metering_2 = '?' THEN NULL 
            ELSE TRY_CAST(Sub_metering_2 AS DECIMAL(10, 3)) 
        END AS laundry_room,
        CASE 
            WHEN Sub_metering_3 = '?' THEN NULL 
            ELSE TRY_CAST(Sub_metering_3 AS DECIMAL(10, 3)) 
        END AS other_appliences
    FROM Bronze.household_power_consumption
),
column_means AS (
    SELECT
        AVG(global_active_power) AS mean_global_active_power,
        AVG(global_reactive_power) AS mean_global_reactive_power,
        AVG(voltage) AS mean_voltage,
        AVG(global_intensity) AS mean_global_intensity,
        AVG(kitchen) AS mean_metring_kitchen,
        AVG(laundry_room) AS mean_laundry_room,
        AVG(other_appliences) AS mean_other_appliences
    FROM transformation
)
-- Insert the transformed data into the Silver table
INSERT INTO sliver.household_power_consumption (
    [date_time],
    global_active_power,
    global_reactive_power,
    voltage,
    global_intensity,
    kitchen,
    laundry_room,
    other_appliences
)
SELECT
    t.dateTime, -- Extract Date part
    ROUND(COALESCE(t.global_active_power, cm.mean_global_active_power), 3) AS global_active_power,
    ROUND(COALESCE(t.global_reactive_power, cm.mean_global_reactive_power), 3) AS global_reactive_power,
    ROUND(COALESCE(t.voltage, cm.mean_voltage), 3) AS voltage,
    ROUND(COALESCE(t.global_intensity, cm.mean_global_intensity), 3) AS global_intensity,
    ROUND(COALESCE(t.kitchen, cm.mean_metring_kitchen), 3) AS kitchen,
    ROUND(COALESCE(t.laundry_room, cm.mean_laundry_room), 3) AS laundry_room,
    ROUND(COALESCE(t.other_appliences, cm.mean_other_appliences), 3) AS other_appliences
FROM transformation t
CROSS JOIN column_means cm;

SELECT * FROM Sliver.household_power_consumption
