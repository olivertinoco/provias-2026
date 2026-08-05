
insert into Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_2023
select t.* from Tramite.ExpedienteDocumentoOrigenDestinoTemporal t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
