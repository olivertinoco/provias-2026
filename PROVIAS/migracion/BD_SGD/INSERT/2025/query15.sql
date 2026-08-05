
insert into Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2025
select t.* from Tramite.ExpedienteDocumentoOrigenDestinoAccion t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
