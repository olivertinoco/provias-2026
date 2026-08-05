
insert into Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_2024
select t.* from Tramite.ExpedienteDocumentoOrigenDestinoTemporal t
WHERE t.FechaCreacionAuditoria >= '20240101'
    AND t.FechaCreacionAuditoria <  '20250101'
