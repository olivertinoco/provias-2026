
insert into Tramite.Expediente_Historico_2023
select*from Tramite.Expediente t
WHERE t.FechaCreacionAuditoria >= '20230101'
    AND t.FechaCreacionAuditoria <  '20240101'
