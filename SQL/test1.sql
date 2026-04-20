SELECT o.name AS ObjectName, o.type_desc AS ObjectType
FROM sys.sql_modules m JOIN sys.objects o
    ON m.object_id = o.object_id
WHERE m.definition LIKE '%SP_Sales%'
