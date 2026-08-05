
insert into Tramite.ExpedienteDocumentoFirmante_Historico_2023
select t.* from Tramite.ExpedienteDocumentoFirmante t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
