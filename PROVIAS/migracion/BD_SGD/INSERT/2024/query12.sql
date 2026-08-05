
insert into Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2024
select t.* from Tramite.ExpedienteDocumentoAdjuntoFirmante t
WHERE t.FechaCreacionAuditoria >= '20240101'
    AND t.FechaCreacionAuditoria <  '20250101'
