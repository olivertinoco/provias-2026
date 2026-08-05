
insert into Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_2025
select t.* from Tramite.ExpedienteDocumentoOrigenDestinoTemporal t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
