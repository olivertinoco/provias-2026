
insert into Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2024
select t.* from Tramite.ExpedienteDocumentoOrigenDestinoAccion t
WHERE t.FechaCreacionAuditoria >= '20240101'
    AND t.FechaCreacionAuditoria <  '20250101'
