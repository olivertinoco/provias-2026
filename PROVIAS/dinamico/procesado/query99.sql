set rowcount 0
go


-- select text from sys.syscomments where id=object_id('dbo.usp_datosEncuesta','p')


-- select*from bd_sgd_arq.sys.procedures order by 1
select*from sys.procedures order by 1






-- Declare @vPeriodo varchar(4), @cta int = 0, @tot int = year(getdate()) - 2022
-- while @cta < @tot begin
--     select @vPeriodo = 2022 + @cta



--     select concat('tramite.Expediente_historico_', @vPeriodo)
--     select @cta+=1
-- end

-- Declare @annio int = 2023
-- Declare @vPeriodo2 varchar(4), @cta2 int = 0, @tot2 int = year(getdate()) - @annio
-- while @cta2 < @tot2 begin
--     select @vPeriodo2 = @annio + @cta2



--     select concat('NUEVO PERIODO: tramite.Expediente_historico_', @vPeriodo2)
--     select @cta2+=1
-- end




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




-- go
-- create or alter procedure dbo.usp_datosEncuesta
-- @data varchar(max)
-- as
-- begin
-- set nocount on

-- ;with tmp001_sep(t,r)as(
--     select*from(values('|','~'))t(SepCamp,SepReg)
-- )
-- select stuff((select top 50 r,
-- Proy_Id, t, Proy_Nombre, t, Proy_Descripcion, t, Proy_ArchivoLogo
-- from dbo.a10_proyectos
-- for xml path, type).value('.','varchar(max)'),1,1,'') data
-- from tmp001_sep

-- -- select top 10
-- -- Proy_Id, Proy_Nombre, Proy_Descripcion, Proy_ArchivoLogo
-- -- from dbo.a10_proyectos

-- select count(1) totalReg from dbo.a10_proyectos

-- end
-- go
