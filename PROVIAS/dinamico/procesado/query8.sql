create or alter PROCEDURE Tramite.paListarExpedientePendienteJefaturaTodos_arq
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
AS
BEGIN
BEGIN TRY
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

if @pIdPeriodo = year(getdate())begin
    RAISERROR('El periodo no debe ser el actual o vacio', 10, 1) with nowait;
    return;
end;

  DECLARE @vIdAreaJefe int=0
  DECLARE @vIdEmpresaJefe int=0
  DECLARE @vIdCargoJefe int=0
  DECLARE @vTablaCargos tABLE(Idcargo int)
  DECLARE @vSql NVARCHAR(MAX), @vIdPeriodo varchar(4) = convert(varchar, @pIdPeriodo)
  INSERT INTO @vTablaCargos
  SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)

   SELECT @vIdAreaJefe=IdArea,@vIdEmpresaJefe=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea
   if rtrim(ltrim(COALESCE(@pBusquedaGeneral,'')))=''
   begin
		select '0¦'
		return;
   end

   IF LEN(COALESCE(@pBusquedaGeneral,''))>6
   BEGIN
    SET @pBusquedaGeneral=-1
   END
   ELSE
   BEGIN
    IF COALESCE(@pBusquedaGeneral,'')<>''
    BEGIN
     IF ISNUMERIC(@pBusquedaGeneral)=0
     BEGIN
      SET @pBusquedaGeneral=-1
     END
    END
   END

   CREATE TABLE #MITABLA(
        IdExpediente int,
        ExpedienteConfidencial bit,
        NTFechaExpediente varchar (10) collate database_default,
        HoraExpediente varchar (5) collate database_default,
        IdCatalogoTipoPrioridad int,
        CatalogoTipoPrioridad varchar (100) collate database_default,
        CatalogoTipoTramite varchar (100) collate database_default,
        ColorCatalogoTipoTramite varchar (100) collate database_default,
        Logueo varchar (100) collate database_default,
        IdPersonaCreador int,
        AsuntoExpediente varchar (8000) collate database_default,
        NumeroFoliosExpediente int,
        ObservacionesExpediente varchar(4000) collate database_default,
        Fecha VARCHAR(20) collate database_default,
        NombreExpediente varchar (100) collate database_default,
        NombreCompletoCreador varchar (100) collate database_default,
        NumeroExpediente int,
        IdExpedienteSeguimiento int,
        FechaMovimiento datetime
    );

   select @vSql = N'
   insert into #MITABLA
   SELECT top 1000 E.IdExpediente,E.ExpedienteConfidencial,E.NTFechaExpediente,E.HoraExpediente,E.IdCatalogoTipoPrioridad,COALESCE(CTP.Descripcion,'''') CatalogoTipoPrioridad,
   COALESCE(CTT.Descripcion,'''') CatalogoTipoTramite,COALESCE(CTT.Detalle,'''') ColorCatalogoTipoTramite,US.Logueo,E.IdPersonaCreador,
   UPPER(E.AsuntoExpediente) AsuntoExpediente,COALESCE(E.NumeroFoliosExpediente,0)NumeroFoliosExpediente,COALESCE(E.ObservacionesExpediente,'''') ObservacionesExpediente,
   CONCAT(E.NTFechaExpediente ,'' '', E.HoraExpediente) Fecha,
   CONCAT(SD.AbreviaturaSerieDocumentalExpediente,RIGHT(1000000+E.NumeroExpediente,6),''-'', E.IdPeriodo) NombreExpediente,
   CASE WHEN COALESCE(E.NombreCompletoCreador,'''')<>'''' THEN COALESCE(E.NombreCompletoCreador,'''') ELSE PE.NombreCompleto END NombreCompletoCreador,
   E.NumeroExpediente, COALESCE(ES.IdExpedienteSeguimiento, 0 )IdExpedienteSeguimiento, NULL FechaMovimiento
   FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
   INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1 AND COALESCE(E.ExpedienteAnulado,0)=0
   INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
   INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
   LEFT JOIN Tramite.ExpedienteSeguimiento_Historico_' + @vIdPeriodo + N' ES
   ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdCargo=0 AND ES.IdPersona=0 AND ES.IdArea=@pIdArea
   LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
   LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
   WHERE E.IdPeriodo = @pIdPeriodo
   and (E.NumeroExpediente = CASE WHEN ISNUMERIC(@pBusquedaGeneral)=1 THEN @pBusquedaGeneral ELSE 0 END OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)
   ORDER BY IdExpediente DESC'

   EXEC sp_executesql @vSql,
	    N'@pIdArea int, @pIdPeriodo int, @pBusquedaGeneral varchar(100)',
		@pIdPeriodo = @pIdPeriodo,
		@pIdArea = @pIdArea,
		@pBusquedaGeneral = @pBusquedaGeneral

	select @vSql = null
	select @vSql = N'
	SELECT(SELECT convert(varchar,COUNT(*)) from #MITABLA)+''¦''+(select STUFF((
	SELECT ''¬''+''0'',''|''+''0'',''|'',''|'',''|0'',
	''|''+CASE WHEN ENP.ExEnlazadoPri<>'''' THEN ENP.ExEnlazadoPri else ENS.ExEnlazadoSec END,
	''|''+CASE WHEN EEN.cantEnlaces>0 THEN ''1'' ELSE ''0'' END,
	''|''+OID.CatalogoTipoOrigen,
	''|''+convert(varchar,E.IdExpediente),
	''|''+convert(varchar,E.ExpedienteConfidencial),
	''|''+E.NTFechaExpediente,
	''|''+E.HoraExpediente,
	''|''+convert(varchar,E.IdCatalogoTipoPrioridad),
	''|''+E.CatalogoTipoPrioridad,
	''|''+E.CatalogoTipoTramite,
	''|''+E.ColorCatalogoTipoTramite,
	''|''+E.Logueo,
	''|''+COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),''sinfotoH.jpg''),
	''|''+replace(E.AsuntoExpediente,''|'','' ''),
	''|''+convert(varchar,E.NumeroFoliosExpediente),
	''|''+replace(E.ObservacionesExpediente,''|'','' ''),
	''|''+E.Fecha,
	''|''+E.NombreExpediente,
	''|''+E.NombreCompletoCreador,
	''|''+convert(varchar,E.NumeroExpediente),
	''|''+convert(varchar,E.IdExpedienteSeguimiento),''|''
	from #MITABLA E
	CROSS APPLY(
		select isnull((select STUFF((
		SELECT ''<div style="margin: 2px;padding: 2px;" class="ui blue label">''+
		CONCAT(SD1.AbreviaturaSerieDocumentalExpediente,RIGHT(1000000 + E1.NumeroExpediente,6), ''-'', E1.IdPeriodo)+''</div>''
		FROM Tramite.ExpedienteEnlazado_Historico_' + @vIdPeriodo + N' EE
		INNER JOIN Tramite.Expediente_Historico_' + @vIdPeriodo + N' e1
		    ON EE.IdExpedienteSecundario=E1.IdExpediente AND E1.EstadoAuditoria=1 AND E1.ExpedienteAnulado=0
		INNER JOIN Tramite.SerieDocumentalExpediente SD1 ON SD1.IdSerieDocumentalExpediente=E1.IdSerieDocumentalExpediente	 and EE.EstadoAuditoria=1
		where EE.IdExpediente=E.IdExpediente
		FOR XML PATH('''')), 1, 0, '''')),'''') ExEnlazadoPri
	) ENP
	CROSS APPLY(
		select isnull((select STUFF((
		SELECT ''<div style="margin: 2px;padding: 2px;" class="ui blue label">''+
		CONCAT(SD1.AbreviaturaSerieDocumentalExpediente,RIGHT(1000000+E1.NumeroExpediente,6), ''-'', E1.IdPeriodo)+''</div>''
		FROM Tramite.ExpedienteEnlazado_Historico_' + @vIdPeriodo + N' EE
		INNER JOIN Tramite.Expediente_Historico_' + @vIdPeriodo + N' e1
		    ON EE.IdExpediente=E1.IdExpediente AND E1.EstadoAuditoria=1 AND E1.ExpedienteAnulado=0
		INNER JOIN Tramite.SerieDocumentalExpediente SD1 ON SD1.IdSerieDocumentalExpediente=E1.IdSerieDocumentalExpediente and EE.EstadoAuditoria=1
		WHERE EE.IdExpedienteSecundario=E.IdExpediente
		FOR XML PATH('''')), 1, 0, '''')),'''') ExEnlazadoSec
	) ENS
	CROSS APPLY(
		SELECT count(ee1.Idexpediente) cantEnlaces
		FROM Tramite.ExpedienteEnlazado_Historico_' + @vIdPeriodo + N' EE1
		INNER JOIN Tramite.Expediente_Historico_' + @vIdPeriodo + N' ex1
		    ON EE1.IdExpedienteSecundario=Ex1.IdExpediente AND Ex1.EstadoAuditoria=1 AND Ex1.ExpedienteAnulado=0
		INNER JOIN Tramite.SerieDocumentalExpediente SD1 ON SD1.IdSerieDocumentalExpediente=Ex1.IdSerieDocumentalExpediente	 and EE1.EstadoAuditoria=1
		where EE1.IdExpediente=E.IdExpediente
	) EEN
	CROSS APPLY(
		select top 1 CONCAT(coalesce(c1.Descripcion,''''),'' '',EX1.NumeroExpedienteExterno) CatalogoTipoOrigen
		from Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ed1
		INNER JOIN Tramite.Expediente_Historico_' + @vIdPeriodo + N' EX1
		    ON EX1.IdExpediente=Ed1.IdExpediente
		INNER JOIN Tramite.Catalogo c1 on c1.IdCatalogo=ed1.IdCatalogoTipoOrigen
		where ed1.EstadoAuditoria=1 and ed1.IdExpediente=E.IdExpediente
		order by ed1.IdExpedienteDocumento
	) OID
	ORDER BY IdExpediente DESC
	OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
	FETCH NEXT @pDimensionPagina ROWS ONLY
	FOR XML PATH('''')), 1, 1, ''''))'


	EXEC sp_executesql @vSql,
        N'@pNumeroPagina int, @pDimensionPagina int',
        @pNumeroPagina = @pNumeroPagina,
        @pDimensionPagina = @pDimensionPagina


 END TRY
 BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() ,
    @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteJefaturaTodos_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
END
GO


EXEC Tramite.paListarExpedientePendienteJefaturaTodos_arq
@pConFiltroFecha=0,
@pFechaInicio='21/05/2026',
@pFechaFin='21/05/2026',
@pConFiltroFechaMovimiento=1,
@pFechaInicioMovimiento='21/05/2026',
@pFechaFinMovimiento='21/05/2026',
@pIdArea=30,
@pIdCatalogoSituacionMovimientoDestino=0,
@pTipoSituacionMovimiento=0,
@pIdAreaOrigen=0,
@pIdAreaDestino=0,
@pIdPeriodo=2025,
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
@pIdUsuarioAuditoria=53721,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral='11477',
@pFlgBusqueda=0


EXEC Tramite.paListarExpedientePendienteJefaturaTodos_arq
@pConFiltroFecha=0,
@pFechaInicio='21/05/2026',
@pFechaFin='21/05/2026',
@pConFiltroFechaMovimiento=1,
@pFechaInicioMovimiento='21/05/2026',
@pFechaFinMovimiento='21/05/2026',
@pIdArea=30,
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
@pIdUsuarioAuditoria=53721,
@pCampoOrdenado=NULL,
@pTipoOrdenacion=NULL,
@pNumeroPagina=1,
@pDimensionPagina=10,
@pBusquedaGeneral='11477',
@pFlgBusqueda=0
