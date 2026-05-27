declare @dato varchar(max), @tabla varchar(200) = 'Tramite.Expediente'


;with tmp001_pk_name as(
    select name pk from dbo.mastertable(@tabla) where is_primary_key = 1
)
,tmp001_tablas as(
    SELECT @tabla tabla, fk.name fk,concat(OBJECT_SCHEMA_NAME(fk.parent_object_id),'.',OBJECT_NAME(fk.parent_object_id)) tabla_hija
    FROM sys.foreign_keys fk
    WHERE fk.referenced_object_id = OBJECT_ID(@tabla)
)
select @dato =(
select ';alter table ', tabla_hija, ' drop constraint ', fk from tmp001_tablas
-- select ';alter table ', tabla_hija, ' add constraint ', fk, ' foreign key (', pk, ') references ', tabla, '(', pk, ')' from tmp001_tablas, tmp001_pk_name
for xml path, type).value('.', 'varchar(max)')
select @dato


set rowcount 10

delete t from Tramite.Expediente t
cross apply Tramite.Expediente_Historico_2022 tt
where t.IdExpediente = tt.IdExpediente
