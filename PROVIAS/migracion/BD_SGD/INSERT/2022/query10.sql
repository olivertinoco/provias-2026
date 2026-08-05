
insert into Tramite.ExpedienteDocumentoFirmante_Historico_2022
select t.* from Tramite.ExpedienteDocumentoFirmante t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
