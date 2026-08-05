
insert into Tramite.ExpedienteDocumento_Historico_2023
select t.* from Tramite.ExpedienteDocumento t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
