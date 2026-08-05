
insert into Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2023
select t.* from Tramite.ExpedienteDocumentoOrigenDestinoAccion t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
