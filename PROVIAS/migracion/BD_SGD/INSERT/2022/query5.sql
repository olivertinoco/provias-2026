
insert into Tramite.ExpedienteDocumentoOrigenDestino_Historico_2022
select t.* from Tramite.ExpedienteDocumentoOrigenDestino t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
