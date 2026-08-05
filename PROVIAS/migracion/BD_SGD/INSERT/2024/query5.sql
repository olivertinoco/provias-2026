
insert into Tramite.ExpedienteDocumentoOrigenDestino_Historico_2024
select t.* from Tramite.ExpedienteDocumentoOrigenDestino t
WHERE t.FechaCreacionAuditoria >= '20240101'
    AND t.FechaCreacionAuditoria <  '20250101'
