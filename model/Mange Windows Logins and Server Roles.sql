-- =================================================================================================
-- Script: Manage Windows Logins and Server Roles
-- Author: Junior Data Engineer
-- Date: 2025-03-14
-- Version: 1.0
-- Description:
-- This script manages Windows logins and server roles in SQL Server. It includes:
-- 1. Querying existing Windows logins.
-- 2. Creating a new Windows login.
-- 3. Granting server-level permissions by adding the login to server roles.
-- =================================================================================================

-- =================================================================================================
-- Section 1: Query Existing Windows Logins
-- Purpose: Retrieve a list of existing Windows logins in the SQL Server instance.
-- =================================================================================================
SELECT 
    name,               -- Name of the login
    type_desc           -- Type description of the login (e.g., WINDOWS_LOGIN)
FROM sys.server_principals 
WHERE type_desc = 'WINDOWS_LOGIN';  -- Filter to show only Windows logins

-- =================================================================================================
-- Section 2: Create a New Windows Login
-- Purpose: Add a new Windows login to the SQL Server instance.
-- Note: Requires administrative privileges to execute.
-- =================================================================================================
-- Create a Windows login for the user 'richard' from the domain 'MSI'
CREATE LOGIN [MSI\richard] FROM WINDOWS;

-- =================================================================================================
-- Section 3: Grant Server-Level Permissions
-- Purpose: Assign server-level permissions to the newly created Windows login.
-- =================================================================================================
-- Option 1: Grant full administrative access by adding the login to the 'sysadmin' role
ALTER SERVER ROLE sysadmin ADD MEMBER [MSI\richard];

-- Option 2: Grant restricted access by adding the login to the 'dbcreator' role
-- Uncomment the following line if you want to grant database creation privileges only
-- ALTER SERVER ROLE dbcreator ADD MEMBER [MSI\richard];