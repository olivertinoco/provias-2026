
insert into Tramite.ExpedienteEnlazado_Historico_2022
select t.* from Tramite.ExpedienteEnlazado t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
