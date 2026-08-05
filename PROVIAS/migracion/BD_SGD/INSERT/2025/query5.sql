
insert into Tramite.ExpedienteDocumentoOrigenDestino_Historico_2025
select t.* from Tramite.ExpedienteDocumentoOrigenDestino t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
