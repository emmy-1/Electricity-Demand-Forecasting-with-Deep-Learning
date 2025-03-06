
/*
=======================================================================================
CREATE OR REPLACE DATABASE AND SCHEMA 
=======================================================================================
The following script creates a database called "ElectricConsumption."
It first checks if the database already exists; if it does, the script drops 
the existing database and creates a new one. After that, it creates schemas for the Medallion 
Architecture, specifically: Bronze, Silver, and Gold.

WARNING:
	If you run this script, it will drop the ElectricConsumption Database and its data content
	if it happens to exist. Please ensure you have backed up the database before running this script. 
	Please visit:https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/create-a-full-database-backup-sql-server?view=sql-server-ver16
	for more information about backing up a database.
*/
-- USE MASTER USER 
USE  master;
GO;

IF EXISTS(SELECT 1 FROM sys.sysdatabases WHERE name = 'ElectricConsumption')
BEGIN
    ALTER DATABASE ElectricConsumption SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ElectricConsumption;
END;
GO

-- CREATE A DATAWAREHOUSE HOUSE
CREATE DATABASE ElectricConsumption;
GO;

-- SWITCH TO ElectricConsumption DATABASE
USE ElectricConsumption;
GO;

/* CREATE EACH SCHEMAS FOR EACH LAYERS IN THE Medallion Architecture 
	Bronze, Silver, and Gold layers
*/

CREATE SCHEMA Bronze;
GO
CREATE SCHEMA Sliver;
GO
CREATE SCHEMA Gold;
GO