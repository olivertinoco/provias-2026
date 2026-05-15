alter PROCEDURE [Tramite].[paListarExpedientePendienteEspecialistaTodos]
	@pConFiltroFecha bit,
	@pFechaInicio varchar(10),
	@pFechaFin varchar(10),
	@pConFiltroFechaMovimiento bit,
	@pFechaInicioMovimiento varchar(10),
	@pFechaFinMovimiento varchar(10),
	@pIdPersona int,
	@pIdEmpleadoPerfil int,
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
	@pDimensionPagina INT,
	@pBusquedaGeneral varchar(100),
	@pFlgBusqueda INT

AS
BEGIN TRY

	DECLARE @vIdCargo int=0
	DECLARE @vIdArea int=0
	DECLARE @vIdEmpresa int=0
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
	--RutaFotoPersona varchar (100),
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

	if rtrim(ltrim(COALESCE(@pBusquedaGeneral,'')))=''
	   begin
			select 0 EsParaAnular,0 DiasPendiente,'' NombrePersonaOrigen,'' NumeroDocumento,0 IdExpedienteDocumento,''NombreExpedientesEnlazados,
				CONVERT(BIT,0) EsPrincipalEnlace,'' CatalogoTipoOrigen,0 IdExpediente,0 ExpedienteConfidencial,'' NTFechaExpediente,
				'' HoraExpediente,0 IdCatalogoTipoPrioridad,'' CatalogoTipoPrioridad,'' CatalogoTipoTramite,'' ColorCatalogoTipoTramite,
				'' Logueo,'' RutaFotoPersona,'' AsuntoExpediente,0 NumeroFoliosExpediente,'' ObservacionesExpediente,'' Fecha,'' NombreExpediente,
				'' NombreCompletoCreador,0 NumeroExpediente,0 IdExpedienteSeguimiento,FechaMovimiento from @MITABLA
			select 0
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

	SELECT @vIdCargo=EP.IdCargo,@vIdArea=EP.IdArea,@vIdEmpresa=ES.IdEmpresa FROM RecursoHumano.EmpleadoPerfil EP INNER JOIN General.EmpresaSede ES ON ES.IdEmpresaSede=EP.IdEmpresaSede where EP.IdEmpleadoPerfil=@pIdEmpleadoPerfil AND EP.EstadoAuditoria=1 AND EP.Activo=1
	--SELECT EP.IdCargo,EP.IdArea,ES.IdEmpresa FROM RecursoHumano.EmpleadoPerfil EP INNER JOIN General.EmpresaSede ES ON ES.IdEmpresaSede=EP.IdEmpresaSede where EP.IdEmpleadoPerfil=@pIdEmpleadoPerfil AND EP.EstadoAuditoria=1 AND EP.Activo=1
	SET LANGUAGE 'SPANISH'
	insert into @MITABLA
	SELECT	top 1000
		--CONVERT(BIT,0) EsParaAnular,
		--0 DiasPendiente,
		--'' NombrePersonaOrigen,
		--'' NumeroDocumento,
		--0 IdExpedienteDocumento,
		--Tramite.funObtenerExpedientesEnlazados(E.IdExpediente) NombreExpedientesEnlazados,
		--Tramite.funEsPrincipalEnlace(E.IdExpediente)EsPrincipalEnlace,
		--Tramite.fnObtenerOrigenInicialDocumento(E.IdExpediente) CatalogoTipoOrigen,
		E.IdExpediente,
		E.ExpedienteConfidencial,
		E.NTFechaExpediente,
		E.HoraExpediente,
		E.IdCatalogoTipoPrioridad,
		CTP.Descripcion CatalogoTipoPrioridad,
		COALESCE(CTT.Descripcion,'') CatalogoTipoTramite,
		COALESCE(CTT.Detalle,'') ColorCatalogoTipoTramite,

		US.Logueo,
		--COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),'sinfotoH.jpg') RutaFotoPersona,
		E.IdPersonaCreador,
		E.AsuntoExpediente,
		E.NumeroFoliosExpediente,
		COALESCE(E.ObservacionesExpediente,'') ObservacionesExpediente,
		CONCAT(E.NTFechaExpediente ,' ', E.HoraExpediente) Fecha,
		CONCAT(SD.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',E.NumeroExpediente),6), '-', E.IdPeriodo) NombreExpediente,
		CASE WHEN COALESCE(E.NombreCompletoCreador,'')<>'' THEN COALESCE(E.NombreCompletoCreador,'') ELSE PE.NombreCompleto END NombreCompletoCreador,
		E.NumeroExpediente,
		COALESCE(ES.IdExpedienteSeguimiento,0)IdExpedienteSeguimiento,
		NULL FechaMovimiento
	FROM
	Tramite.Expediente E WITH (NOLOCK)
	INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1  AND COALESCE(E.ExpedienteAnulado,0)=0
	INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
	INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
	LEFT JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK) ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdEmpresa=@vIdEmpresa AND ES.IdCargo=@vIdCargo AND ES.IdPersona=@pIdPersona AND ES.IdArea=@vIdArea
	LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
	LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
	WHERE-- (E.NumeroExpediente =  @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)
	E.IdPeriodo = @pIdPeriodo and
	(E.NumeroExpediente =  CASE WHEN @pBusquedaGeneral<>'' OR @pBusquedaGeneral IS NOT NULL THEN  CASE WHEN ISNUMERIC(@pBusquedaGeneral)=1 THEN @pBusquedaGeneral ELSE E.NumeroExpediente END ELSE E.NumeroExpediente END)
	ORDER BY E.IdExpediente	DESC
	--OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
	--FETCH NEXT @pDimensionPagina ROWS ONLY

	select
		CONVERT(BIT,0) EsParaAnular,
		0 DiasPendiente,
		'' NombrePersonaOrigen,
		'' NumeroDocumento,
		0 IdExpedienteDocumento,
		CASE WHEN ENP.ExEnlazadoPri<>'' THEN replace(replace(ENP.ExEnlazadoPri,'&lt;','<'),'&gt;','>') else replace(replace(ENS.ExEnlazadoSec,'&lt;','<'),'&gt;','>') END NombreExpedientesEnlazados, --Tramite.funObtenerExpedientesEnlazados(E.IdExpediente) NombreExpedientesEnlazados,
		CONVERT(BIT,CASE WHEN EE.cantEnlaces>0 THEN 1 ELSE 0 END) EsPrincipalEnlace, --Tramite.funEsPrincipalEnlace(E.IdExpediente)EsPrincipalEnlace,
		OID.CatalogoTipoOrigen, --Tramite.fnObtenerOrigenInicialDocumento(E.IdExpediente) CatalogoTipoOrigen,
		E.IdExpediente,
		E.ExpedienteConfidencial,
		E.NTFechaExpediente,
		E.HoraExpediente,
		E.IdCatalogoTipoPrioridad,
		E.CatalogoTipoPrioridad,
		E.CatalogoTipoTramite,
		E.ColorCatalogoTipoTramite,
		E.Logueo,
		ISNULL(RFP.RutaFotoPersona,'sinfotoH.jpg') RutaFotoPersona,
		E.AsuntoExpediente,
		E.NumeroFoliosExpediente,
		E.ObservacionesExpediente,
		E.Fecha,
		E.NombreExpediente,
		E.NombreCompletoCreador,
		E.NumeroExpediente,
		E.IdExpedienteSeguimiento,
		E.FechaMovimiento
	from @MITABLA E
	OUTER APPLY(
		SELECT TOP 1 case when COALESCE(U1.RutaArchivoFoto,'') ='' then CASE WHEN COALESCE(Pr1.Sexo,0)=0 then 'sinfotoH.jpg' else 'sinfotoM.jpg' end else U1.RutaArchivoFoto end RutaFotoPersona
		FROM Seguridad.Usuario U1
		INNER JOIN General.Persona PR1 ON PR1.IdPersona=U1.IdPersona
		WHERE U1.EstadoAuditoria=1 and pr1.IdPersona=E.IdPersonaCreador AND U1.Bloqueado=0
	)RFP
	CROSS APPLY(
		select isnull((select STUFF((
		SELECT distinct '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
		CONCAT(SD1.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',E1.NumeroExpediente),6), '-', E1.IdPeriodo)
		+'</div> '
		FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
		INNER JOIN Tramite.Expediente e1  WITH (NOLOCK) ON EE.IdExpedienteSecundario=E1.IdExpediente AND E1.EstadoAuditoria=1 AND E1.ExpedienteAnulado=0
		INNER JOIN Tramite.SerieDocumentalExpediente SD1 ON SD1.IdSerieDocumentalExpediente=E1.IdSerieDocumentalExpediente	 and EE.EstadoAuditoria=1
		where EE.IdExpediente=E.IdExpediente
		FOR XML PATH('')), 1, 0, '')),'') ExEnlazadoPri
	) ENP
	CROSS APPLY(
		select isnull((select STUFF((
		SELECT distinct '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
		CONCAT(SD1.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',E1.NumeroExpediente),6), '-', E1.IdPeriodo)
		+'</div> '
		FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
		INNER JOIN Tramite.Expediente e1 WITH (NOLOCK) ON EE.IdExpediente=E1.IdExpediente AND E1.EstadoAuditoria=1 AND E1.ExpedienteAnulado=0
		INNER JOIN Tramite.SerieDocumentalExpediente SD1 ON SD1.IdSerieDocumentalExpediente=E1.IdSerieDocumentalExpediente and EE.EstadoAuditoria=1
		WHERE EE.IdExpedienteSecundario=E.IdExpediente
		FOR XML PATH('')), 1, 0, '')),'') ExEnlazadoSec
	) ENS
	CROSS APPLY(
		SELECT count(ee.Idexpediente) cantEnlaces
		FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
		INNER JOIN Tramite.Expediente ex WITH (NOLOCK) ON EE.IdExpedienteSecundario=Ex.IdExpediente AND Ex.EstadoAuditoria=1 AND Ex.ExpedienteAnulado=0
		INNER JOIN Tramite.SerieDocumentalExpediente SD1 ON SD1.IdSerieDocumentalExpediente=Ex.IdSerieDocumentalExpediente	 and EE.EstadoAuditoria=1
		where EE.IdExpediente=E.IdExpediente
	) EE
	CROSS APPLY(
		select top 1 CONCAT(coalesce(c.Descripcion,''),' ',EX.NumeroExpedienteExterno) CatalogoTipoOrigen
		from Tramite.ExpedienteDocumento ed1  WITH (NOLOCK)
		INNER JOIN Tramite.Expediente EX  WITH (NOLOCK) ON EX.IdExpediente=Ed1.IdExpediente
		INNER JOIN Tramite.Catalogo c on c.IdCatalogo=ed1.IdCatalogoTipoOrigen
		where ed1.EstadoAuditoria=1 and ed1.IdExpediente=E.IdExpediente
		order by ed1.IdExpedienteDocumento
	) OID
	ORDER BY IdExpediente DESC
	OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
	FETCH NEXT @pDimensionPagina ROWS ONLY

	select count(*) from @MITABLA
	--SELECT COUNT(*)	FROM
	--Tramite.Expediente E WITH (NOLOCK)
	--INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1  AND COALESCE(E.ExpedienteAnulado,0)=0
	--INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
	--INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
	--LEFT JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK) ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdEmpresa=@vIdEmpresa AND ES.IdCargo=@vIdCargo AND ES.IdPersona=@pIdPersona AND ES.IdArea=@vIdArea
	--LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
	--LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
	--WHERE-- (E.NumeroExpediente =  @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)
	-- (E.NumeroExpediente =  CASE WHEN @pBusquedaGeneral<>'' OR @pBusquedaGeneral IS NOT NULL THEN  CASE WHEN ISNUMERIC(@pBusquedaGeneral)=1 THEN @pBusquedaGeneral ELSE E.NumeroExpediente END ELSE E.NumeroExpediente END)

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaTodos',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
