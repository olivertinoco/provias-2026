
insert into Tramite.ExpedienteDocumentoFirmante_Historico_2025
select t.* from Tramite.ExpedienteDocumentoFirmante t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
