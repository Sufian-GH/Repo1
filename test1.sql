-- =============================================================
-- Description : Retrieves all database objects whose SQL
--               definition contains the phrase 'SP_Sales'.
-- Tables Used : sys.sql_modules, sys.objects
-- Returns     : ObjectName  - Name of the matching object
--               ObjectType  - Descriptive type of the object
--                             (e.g. SQL_STORED_PROCEDURE,
--                              SQL_SCALAR_FUNCTION, VIEW, etc.)
-- =============================================================
SELECT o.name AS ObjectName, o.type_desc AS ObjectType
FROM sys.sql_modules m JOIN sys.objects o
    ON m.object_id = o.object_id
WHERE m.definition LIKE '%SP_Sales%'