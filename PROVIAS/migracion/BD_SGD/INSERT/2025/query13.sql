
insert into Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_2025
select t.* from Tramite.ExpedienteDocumentoAdjuntoTemporal t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
