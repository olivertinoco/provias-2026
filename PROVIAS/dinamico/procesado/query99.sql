set rowcount 10

select @@version


Declare @vPeriodo varchar(4), @cta int = 0, @tot int = year(getdate()) - 2022
while @cta < @tot begin
    select @vPeriodo = 2022 + @cta



    select concat('tramite.Expediente_historico_', @vPeriodo)
    select @cta+=1
end



-- SELECT string_agg(CONCAT('(',case when CA2.OrdenItem='22' then '2' else CA2.OrdenItem end,')'), ', ')within group(order by A2.IdExpedienteDocumentoOrigenDestino)
-- from  Tramite.ExpedienteDocumentoOrigenDestinoAccion A2
-- INNER JOIN Tramite.Catalogo CA2 ON CA2.IdCatalogo=A2.IdCatalogoTipoAccion
-- where A2.IdExpedienteDocumentoOrigenDestino=@pIdExpedienteDocumentoOrigenDestino and A2.EstadoAuditoria=1





-- SELECT string_agg(isnull(EDOD4.DestinatarioDestino, concat(P4.NombreCompleto,' ',isnull(EM4.NombreEmpresa,'EXTERNO'),' ',A4.NombreArea,' ',C4.NombreCargo)), ', ')within group(order by EDOD4.IdExpedienteDocumentoOrigen)
-- FROM Tramite.ExpedienteDocumentoOrigenDestino EDOD4
-- LEFT JOIN General.Cargo C4 ON C4.IdCargo=EDOD4.IdCargoDestino
-- LEFT JOIN General.Area A4 ON A4.IdArea=EDOD4.IdAreaDestino
-- LEFT JOIN General.Empresa EM4 ON EM4.IdEmpresa=EDOD4.IdEmpresaDestino
-- LEFT JOIN General.Persona P4 ON P4.IdPersona=EDOD4.IdPersonaDestino
-- WHERE EDOD4.IdExpedienteDocumentoOrigen=@pIdExpedienteDocumentoOrigen AND EDOD4.EsInicial<>0 and EDOD4.EstadoAuditoria=1




return
-- select @Lista = concat(RutaArchivo,'|', @Lista)
-- from Tramite.ExpedienteDocumentoVisualizacion

;with tempDatos as(
    select top 10 RutaArchivo, idExpedienteDocumentoVisualizacion
    from Tramite.ExpedienteDocumentoVisualizacion order by idExpedienteDocumentoVisualizacion
)
select string_agg( concat('(', cast(RutaArchivo as varchar(max)), ')'), ', ')within group(order by idExpedienteDocumentoVisualizacion)
from tempDatos
