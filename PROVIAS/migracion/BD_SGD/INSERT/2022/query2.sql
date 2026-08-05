
insert into Tramite.Expediente_Historico_2022
select*from Tramite.Expediente t
WHERE t.FechaCreacionAuditoria >= '20220101'
    AND t.FechaCreacionAuditoria <  '20230101'
