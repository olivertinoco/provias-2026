
insert into Tramite.Expediente_Historico_2024
select*from Tramite.Expediente t
WHERE t.FechaCreacionAuditoria >= '20240101'
    AND t.FechaCreacionAuditoria <  '20250101'
