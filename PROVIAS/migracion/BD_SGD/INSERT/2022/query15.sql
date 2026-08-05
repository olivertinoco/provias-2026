
insert into Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2022
select t.* from Tramite.ExpedienteDocumentoOrigenDestinoAccion t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
