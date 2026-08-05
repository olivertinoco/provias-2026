
insert into Tramite.ExpedienteDocumentoOrigenDestino_Historico_2023
select t.* from Tramite.ExpedienteDocumentoOrigenDestino t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
