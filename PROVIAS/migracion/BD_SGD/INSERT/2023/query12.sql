
insert into Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2023
select t.* from Tramite.ExpedienteDocumentoAdjuntoFirmante t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
