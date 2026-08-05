
insert into Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_2023
select t.* from Tramite.ExpedienteDocumentoAdjuntoTemporal t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
