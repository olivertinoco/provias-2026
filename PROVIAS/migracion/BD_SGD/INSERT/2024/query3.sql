
insert into Tramite.ExpedienteDocumento_Historico_2024
select t.* from Tramite.ExpedienteDocumento t
WHERE t.FechaCreacionAuditoria >= '20240101'
    AND t.FechaCreacionAuditoria <  '20250101'
