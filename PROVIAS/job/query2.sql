-- ALTER PROCEDURE [Tramite].[paListarExpedientePendienteJefaturaTodosFosCad]
declare
 @pConFiltroFecha bit,
 @pFechaInicio varchar(10),
 @pFechaFin varchar(10),
 @pConFiltroFechaMovimiento bit,
 @pFechaInicioMovimiento varchar(10),
 @pFechaFinMovimiento varchar(10),
 @pIdArea int,
 @pIdCatalogoSituacionMovimientoDestino INT,
 @pTipoSituacionMovimiento int,
 @pIdAreaOrigen int,
 @pIdAreaDestino int,
 @pIdPeriodo int,
 @pIdCatalogoTipoPrioridad int,
 @pIdCatalogoTipoTramite int,
 @pIdCatalogoTipoDocumento int,
 @pNumeroExpediente varchar(100),
 @pNumeroDocumento varchar(100),
 @pPersonaDesde varchar(100),
 @pPersonaPara varchar(100),
 @pIdTipoIngreso int,
 @pFechaDocumento  varchar(100),
 @pEmisorExpediente varchar(100),
 @pAsuntoExpediente  varchar(100),
 @pIdUsuarioAuditoria int,
 @pCampoOrdenado varchar(50),
 @pTipoOrdenacion varchar(4),
 @pNumeroPagina INT,
 @pDimensionPagina  INT,
 @pBusquedaGeneral varchar(100),
 @pFlgBusqueda int
-- AS
--  BEGIN TRY

set tran isolation level read uncommitted
set nocount on


select
    @pConFiltroFecha=0,
    @pFechaInicio='06/05/2026',
    @pFechaFin='06/05/2026',
    @pConFiltroFechaMovimiento=0,
    @pFechaInicioMovimiento='06/05/2026',
    @pFechaFinMovimiento='06/05/2026',
    @pIdArea=79,
    @pIdCatalogoSituacionMovimientoDestino=0,
    @pTipoSituacionMovimiento=0,
    @pIdAreaOrigen=0,
    @pIdAreaDestino=0,
    @pIdPeriodo=2026,
    @pIdCatalogoTipoPrioridad=0,
    @pIdCatalogoTipoTramite=0,
    @pIdCatalogoTipoDocumento=0,
    @pNumeroExpediente='',
    @pNumeroDocumento='',
    @pPersonaDesde='',
    @pPersonaPara='',
    @pIdTipoIngreso=0,
    @pFechaDocumento='',
    @pEmisorExpediente='',
    @pAsuntoExpediente='',
    @pIdUsuarioAuditoria=349,
    @pCampoOrdenado=NULL,
    @pTipoOrdenacion=NULL,
    @pNumeroPagina=1,
    @pDimensionPagina=10,
    @pBusquedaGeneral='11477',
    @pFlgBusqueda=0


  -- DECLARE @vIdAreaJefe int=0
  -- DECLARE @vIdEmpresaJefe int=0
  -- DECLARE @vIdCargoJefe int=0

  -- DECLARE @vTablaCargos tABLE(Idcargo int)
  -- INSERT INTO @vTablaCargos
  -- SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)

  --  SELECT @vIdAreaJefe=IdArea,@vIdEmpresaJefe=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea

  --  select @vIdAreaJefe, @pIdArea, @vIdEmpresaJefe

   declare @conBus int
   select @conBus = case when @pBusquedaGeneral is null or @pBusquedaGeneral = '' then 1 else 0 end
   if @conBus = 1 begin
        select '0¦'
        return
   end

   DECLARE @MITABLA TABLE (
		IdExpediente int,
		ExpedienteConfidencial bit,
		NTFechaExpediente varchar (10),
		HoraExpediente varchar (5),
		IdCatalogoTipoPrioridad int,
		CatalogoTipoPrioridad varchar (100),
		CatalogoTipoTramite varchar (100),
		ColorCatalogoTipoTramite varchar (100),
		Logueo varchar (100),
		IdPersonaCreador int,
		AsuntoExpediente varchar (8000),
		NumeroFoliosExpediente int,
		ObservacionesExpediente varchar(4000),
		Fecha VARCHAR(20),
		NombreExpediente varchar (100),
		NombreCompletoCreador varchar (100),
		NumeroExpediente int,
		IdExpedienteSeguimiento int,
		FechaMovimiento datetime);


   -- ;with tmp001_serieDocumental as(
   --     select*from(values(1,'E-'),(2,'I-'))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
   -- )
   -- insert into @MITABLA
   -- select top 1000
   --     t1.IdExpediente,
   --     t1.ExpedienteConfidencial,
   --     t1.NTFechaExpediente,
   --     t1.HoraExpediente,
   --     t1.IdCatalogoTipoPrioridad,
   --     isnull(c1.Descripcion,'') CatalogoTipoPrioridad,
   --     isnull(c2.Descripcion,'') CatalogoTipoTramite,
   --     isnull(c2.Detalle,'') ColorCatalogoTipoTramite,
   --     isnull(su.Logueo, '') Logueo,
   --     t1.IdPersonaCreador,
   --     UPPER(t1.AsuntoExpediente) AsuntoExpediente,
   --     isnull(t1.NumeroFoliosExpediente,0)NumeroFoliosExpediente,
   --     isnull(t1.ObservacionesExpediente,'') ObservacionesExpediente,
   --     concat(t1.NTFechaExpediente ,' ', t1.HoraExpediente) Fecha,
   --     concat(sd.AbreviaturaSerieDocumentalExpediente, right(1000000+t1.NumeroExpediente,6),'-', t1.IdPeriodo) NombreExpediente,
   --     isnull(t1.NombreCompletoCreador, p.NombreCompleto) NombreCompletoCreador,
   --     t1.NumeroExpediente,
   --     isnull(ss.IdExpedienteSeguimiento, 0 )IdExpedienteSeguimiento,
   --     NULL FechaMovimiento
   -- from Tramite.Expediente t1
   -- inner join tmp001_serieDocumental sd
   --     on sd.IdSerieDocumentalExpediente = t1.IdSerieDocumentalExpediente
   -- inner join Tramite.Catalogo c1
   --     on c1.IdCatalogo = t1.IdCatalogoTipoPrioridad
   -- left join Tramite.Catalogo c2
   --     on c2.IdCatalogo = t1.IdCatalogoTipoTramite
   -- left join Seguridad.Usuario su
   --     on su.IdUsuario = t1.IdUsuarioCreacionAuditoria
   -- left join General.Persona p
   --     on p.IdPersona = t1.IdPersonaCreador
   -- left join Tramite.ExpedienteSeguimiento ss
   --     on  ss.IdExpediente = t1.IdExpediente
   --     and ss.IdArea    = @pIdArea
   --     and ss.IdCargo   = 0
   --     and ss.IdPersona = 0
   --     and ss.EstadoAuditoria   = 1
   -- where   t1.EstadoAuditoria   = 1
   --     and t1.ExpedienteAnulado = 0
   --     and t1.IdSerieDocumentalExpediente in (1,2)
   --     and t1.IdPeriodo = @pIdPeriodo
   --     and (@conBus = 1 or t1.NumeroExpediente = @pBusquedaGeneral)
   -- order by t1.IdExpediente desc




   ;with tmp001_serieDocumental as(
       select*from(values(1,'E-'),(2,'I-'))sd(IdSerieDocumentalExpediente, AbreviaturaSerieDocumentalExpediente)
   )
   -- insert into @MITABLA
   select top 1000 t1.*
       -- t1.IdExpediente,
       -- t1.ExpedienteConfidencial,
       -- t1.NTFechaExpediente,
       -- t1.HoraExpediente,
       -- t1.IdCatalogoTipoPrioridad,
       -- isnull(c1.Descripcion,'') CatalogoTipoPrioridad,
       -- isnull(c2.Descripcion,'') CatalogoTipoTramite,
       -- isnull(c2.Detalle,'') ColorCatalogoTipoTramite,
       -- isnull(su.Logueo, '') Logueo,
       -- t1.IdPersonaCreador,
       -- UPPER(t1.AsuntoExpediente) AsuntoExpediente,
       -- isnull(t1.NumeroFoliosExpediente,0)NumeroFoliosExpediente,
       -- isnull(t1.ObservacionesExpediente,'') ObservacionesExpediente,
       -- concat(t1.NTFechaExpediente ,' ', t1.HoraExpediente) Fecha,
       -- concat(sd.AbreviaturaSerieDocumentalExpediente, right(1000000+t1.NumeroExpediente,6),'-', t1.IdPeriodo) NombreExpediente,
       -- isnull(t1.NombreCompletoCreador, p.NombreCompleto) NombreCompletoCreador,
       -- t1.NumeroExpediente,
       -- isnull(ss.IdExpedienteSeguimiento, 0 )IdExpedienteSeguimiento,
       -- NULL FechaMovimiento
   from Tramite.Expediente t1
   cross apply tmp001_serieDocumental sd
   cross apply Tramite.Catalogo c1
   -- outer apply(select*from Tramite.Catalogo c2 where c2.IdCatalogo = t1.IdCatalogoTipoTramite)c2
   -- outer apply(select*from Seguridad.Usuario su where su.IdUsuario = t1.IdUsuarioCreacionAuditoria)su
   -- outer apply(select*from General.Persona p where p.IdPersona = t1.IdPersonaCreador)p
   outer apply(select*from Tramite.ExpedienteSeguimiento ss
        where   ss.IdExpediente = t1.IdExpediente
            and ss.IdArea    = @pIdArea
            and ss.IdCargo   = 0
            and ss.IdPersona = 0
            and ss.EstadoAuditoria   = 1)ss
    where   t1.EstadoAuditoria   = 1
        and t1.ExpedienteAnulado = 0
        and t1.IdSerieDocumentalExpediente in (1,2)
        and t1.IdPeriodo = @pIdPeriodo
        and (@conBus = 1 or t1.NumeroExpediente = @pBusquedaGeneral)
    order by t1.IdExpediente desc





   select*from @MITABLA
   return

 --    select (SELECT convert(varchar,COUNT(*)) from @MITABLA)+'¦'+
	-- (select STUFF((
	SELECT
	'¬'+'0', --EsParaAnular,
	'|'+'0', --DiasPendiente
	'|', --NombrePersonaOrigen,
	'|', --NumeroDocumento,
	'|0', --IdExpedienteDocumento,
	'|'+CASE WHEN ENP.ExEnlazadoPri<>'' THEN ENP.ExEnlazadoPri else ENS.ExEnlazadoSec END, --NombreExpedientesEnlazados,
	'|'+CASE WHEN EEN.cantEnlaces>0 THEN '1' ELSE '0' END, --EsPrincipalEnlace,
	'|'+OID.CatalogoTipoOrigen,
	'|'+convert(varchar,E.IdExpediente),
	'|'+convert(varchar,E.ExpedienteConfidencial),
	'|'+E.NTFechaExpediente,
	'|'+E.HoraExpediente,
	'|'+convert(varchar,E.IdCatalogoTipoPrioridad),
	'|'+E.CatalogoTipoPrioridad,
	'|'+E.CatalogoTipoTramite,
	'|'+E.ColorCatalogoTipoTramite,
	'|'+E.Logueo,
	'|'+COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),'sinfotoH.jpg'), --RutaFotoPersona,
	'|'+replace(E.AsuntoExpediente,'|',' '),
	'|'+convert(varchar,E.NumeroFoliosExpediente),
	'|'+replace(E.ObservacionesExpediente,'|',' '),
	'|'+E.Fecha,
	'|'+E.NombreExpediente,
	'|'+E.NombreCompletoCreador,
	'|'+convert(varchar,E.NumeroExpediente),
	'|'+convert(varchar,E.IdExpedienteSeguimiento),
	'|'
	from @MITABLA E
	CROSS APPLY(
		select isnull((select STUFF((
		SELECT '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
		CONCAT(SD1.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',E1.NumeroExpediente),6), '-', E1.IdPeriodo)
		+'</div>'
		FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
		INNER JOIN Tramite.Expediente e1  WITH (NOLOCK) ON EE.IdExpedienteSecundario=E1.IdExpediente AND E1.EstadoAuditoria=1 AND E1.ExpedienteAnulado=0
		INNER JOIN Tramite.SerieDocumentalExpediente SD1 ON SD1.IdSerieDocumentalExpediente=E1.IdSerieDocumentalExpediente	 and EE.EstadoAuditoria=1

		where EE.IdExpediente=E.IdExpediente
		FOR XML PATH('')), 1, 0, '')),'') ExEnlazadoPri
	) ENP
	CROSS APPLY(
		select isnull((select STUFF((
		SELECT '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
		CONCAT(SD1.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',E1.NumeroExpediente),6), '-', E1.IdPeriodo)
		+'</div>'
		FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
		INNER JOIN Tramite.Expediente e1 WITH (NOLOCK) ON EE.IdExpediente=E1.IdExpediente AND E1.EstadoAuditoria=1 AND E1.ExpedienteAnulado=0
		INNER JOIN Tramite.SerieDocumentalExpediente SD1 ON SD1.IdSerieDocumentalExpediente=E1.IdSerieDocumentalExpediente and EE.EstadoAuditoria=1
		WHERE EE.IdExpedienteSecundario=E.IdExpediente
		FOR XML PATH('')), 1, 0, '')),'') ExEnlazadoSec
	) ENS
	CROSS APPLY(
		SELECT count(ee1.Idexpediente) cantEnlaces
		FROM Tramite.ExpedienteEnlazado EE1  WITH (NOLOCK)
		INNER JOIN Tramite.Expediente ex1 WITH (NOLOCK) ON EE1.IdExpedienteSecundario=Ex1.IdExpediente AND Ex1.EstadoAuditoria=1 AND Ex1.ExpedienteAnulado=0
		INNER JOIN Tramite.SerieDocumentalExpediente SD1 ON SD1.IdSerieDocumentalExpediente=Ex1.IdSerieDocumentalExpediente	 and EE1.EstadoAuditoria=1
		where EE1.IdExpediente=E.IdExpediente
	) EEN
	CROSS APPLY(
		select top 1 CONCAT(coalesce(c1.Descripcion,''),' ',EX1.NumeroExpedienteExterno) CatalogoTipoOrigen
		from Tramite.ExpedienteDocumento ed1  WITH (NOLOCK)
		INNER JOIN Tramite.Expediente EX1 WITH (NOLOCK) ON EX1.IdExpediente=Ed1.IdExpediente
		INNER JOIN Tramite.Catalogo c1 on c1.IdCatalogo=ed1.IdCatalogoTipoOrigen
		where ed1.EstadoAuditoria=1 and ed1.IdExpediente=E.IdExpediente
		order by ed1.IdExpedienteDocumento
	) OID
	ORDER BY IdExpediente DESC
	OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
	FETCH NEXT @pDimensionPagina ROWS ONLY
	-- FOR XML PATH('')), 1, 1, ''))

 -- END TRY
 -- BEGIN CATCH
 --   DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
 --   SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteJefaturaTodos',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
 --   EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
 --  END CATCH
