declare @data varchar(max)='\
User8UIT|\
UserSIGANET|\
UserWEBSOC|\
usr_appmovil|\
u_repositorio|\
u_reportingservices|\
u_powerbi|\
u_SIGO|\
u_API'


select value usuarios into #tmp001_usuarios
from dbo.udf_split(@data, default)


-- select*from #tmp001_usuarios


SELECT
    dp.name AS Usuario,
    concat(object_schema_name(o.object_id),'.', o.name) AS StoredProcedure,
    p.permission_name,
    p.state_desc
FROM sys.database_permissions p
INNER JOIN sys.objects o
    ON p.major_id = o.object_id
INNER JOIN sys.database_principals dp
    ON p.grantee_principal_id = dp.principal_id
INNER JOIN #tmp001_usuarios UU
    ON UU.usuarios = dp.name
WHERE o.type = 'P'
order by UU.usuarios, object_schema_name(o.object_id), StoredProcedure

--   SELECT
--       dp.name AS Usuario,
--       s.name AS SchemaName,
--       p.permission_name,
--       p.state_desc
--   FROM sys.database_permissions p
--   INNER JOIN sys.schemas s
--       ON p.major_id = s.schema_id
--   INNER JOIN sys.database_principals dp
--       ON dp.principal_id = p.grantee_principal_id
--     INNER JOIN #tmp001_usuarios UU
--         ON UU.usuarios = dp.name
-- order by UU.usuarios
