
insert into Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_2024
select t.* from Tramite.ExpedienteDocumentoAdjuntoTemporal t
WHERE t.FechaCreacionAuditoria >= '20240101'
    AND t.FechaCreacionAuditoria <  '20250101'
