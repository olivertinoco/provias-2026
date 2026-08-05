
insert into Tramite.ExpedienteEnlazado_Historico_2023
select t.* from Tramite.ExpedienteEnlazado t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
