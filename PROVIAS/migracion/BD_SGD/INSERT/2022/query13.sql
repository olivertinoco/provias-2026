
insert into Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_2022
select t.* from Tramite.ExpedienteDocumentoAdjuntoTemporal t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
