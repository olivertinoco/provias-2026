
insert into Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2025
select t.* from Tramite.ExpedienteDocumentoAdjuntoFirmante t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
