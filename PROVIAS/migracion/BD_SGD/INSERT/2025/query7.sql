
insert into Tramite.ExpedienteEnlazado_Historico_2025
select t.* from Tramite.ExpedienteEnlazado t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
