
insert into Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2022
select t.* from Tramite.ExpedienteDocumentoAdjuntoFirmante t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
