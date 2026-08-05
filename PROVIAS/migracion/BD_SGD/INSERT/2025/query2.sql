
insert into Tramite.Expediente_Historico_2025
select*from Tramite.Expediente t
WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'
