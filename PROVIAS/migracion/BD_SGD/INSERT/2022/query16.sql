
insert into Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_2022
select t.* from Tramite.ExpedienteDocumentoOrigenDestinoTemporal t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
