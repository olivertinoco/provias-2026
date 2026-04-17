ORIGINAL .....
CREATE PROCEDURE [Tramite].[paListarExpedientePendienteJefaturaPorRecibirFosCad]
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
BEGIN TRY

	DECLARE @vIdAreaJefe int=0
	DECLARE @vIdEmpresaJefe int=0
	DECLARE @vIdCargoJefe int=0
	--DECLARE @vTablaCargos tABLE(Idcargo int)
	--INSERT INTO @vTablaCargos
	--SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)

	if @pIdPeriodo = 0
	set @pIdPeriodo = year(getdate())

	SELECT @vIdAreaJefe=IdArea,@vIdEmpresaJefe=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea
	--DECLARE @vTablaExpediente TABLE(IdExpediente int)
	DECLARE @vTablaExpediente TABLE(IdExpediente int, FechaMovimiento Datetime,EsParaAnular int,DiasPendiente int,NombrePersonaOrigen varchar(max),NumeroDocumento varchar(max),IdExpedienteDocumento int);
	--DECLARE @MITABLA TABLE (
	--IdExpediente int,
	--ExpedienteConfidencial bit,
	--NTFechaExpediente varchar (10),
	--HoraExpediente varchar (5),
	--IdCatalogoTipoPrioridad int,
	--CatalogoTipoPrioridad varchar (100),
	--CatalogoTipoTramite varchar (100),
	--ColorCatalogoTipoTramite varchar (100),
	--Logueo varchar (100),
	--RutaFotoPersona varchar (100),
	--AsuntoExpediente varchar (8000),
	--NumeroFoliosExpediente int,
	--ObservacionesExpediente varchar(4000),
	--Fecha VARCHAR(20),
	--NombreExpediente varchar (100),
	--NombreCompletoCreador varchar (100),
	--NumeroExpediente int,
	--IdExpedienteSeguimiento int,
	--FechaMovimiento datetime);

	IF ISNUMERIC(@pBusquedaGeneral)=1 OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=''
	BEGIN
		WITH Cargo_CTE	AS (SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
		INSERT INTO @vTablaExpediente
		SELECT E.IdExpediente,
			MAX(CONVERT(DATETIME,edod.FechaDestino +' ' + edod.HoraDestino)) FechaMovimiento,
			0 EsParaAnular,
			MAX(CASE WHEN  COALESCE(EDOD.FechaDestinoRecepciona,'')='' THEN CASE WHEN DATEDIFF(DAY,CONVERT(DATE, EDO.FechaOrigen),GETDATE())<=0 then 0 ELSE DATEDIFF(DAY,CONVERT(DATE, EDOD.FechaDestino),GETDATE()) END ELSE 0 END) DiasPendiente,
			MAX(CASE WHEN COALESCE(EDO.IdempresaOrigen,0)=0 THEN ed.NombreCompletoEmisor  ELSE A.NombreArea END) NombrePersonaOrigen,
			MAX('<button type="button" data-toggle="tooltip" title="'+COALESCE(EDOD.MotivoArchivado,'')+'" class="btn ui blue label" onclick="MostrarDocumentoPdfExp('''+ED.RutaArchivoDocumento+''','+CONVERT(VARCHAR,ed.IdExpedienteDocumento) +')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:10px;line-height:13px;padding-top:6px;">'+CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END+'</label>') NumeroDocumento,
			MAX(ed.IdExpedienteDocumento) IdExpedienteDocumento
		FROM
		Tramite.Expediente E WITH (NOLOCK)
		INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
		INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK)  ON E.IdExpediente=ED.IdExpediente AND ED.EstadoAuditoria=1 AND COALESCE(E.ExpedienteAnulado,0)=0 AND E.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1
		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK) ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen and edod.EstadoAuditoria=1
		left join General.Area A ON A.IdArea=EDO.IdAreaOrigen
		LEFT JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
		where COALESCE(E.ExpedienteAnulado,0)=0 AND E.EstadoAuditoria=1
		AND EDOD.IdAreaDestino=@vIdAreaJefe
		AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM Cargo_CTE)
		AND EDOD.IdEmpresaDestino=@vIdEmpresaJefe
		AND EDOD.IdCatalogoSituacionMovimientoDestino=4
		AND ED.FgEnEsperaFirmaDigital=0
		AND (E.NumeroExpediente =  @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)
		group by E.IdExpediente
	END
	--INSERT INTO @MITABLA
	select
		(SELECT convert(varchar,count(*)) FROM @vTablaExpediente)+'¦'+
		(select STUFF((
		SELECT
		'¬'+convert(varchar,tE.EsParaAnular),
		'|'+convert(varchar,tE.DiasPendiente),
		'|'+tE.NombrePersonaOrigen,
		'|'+replace(tE.NumeroDocumento,'|',''),
		'|'+convert(varchar,tE.IdExpedienteDocumento),
		--Tramite.funObtenerExpedientesEnlazados(E.IdExpediente) NombreExpedientesEnlazados,
		'|'+CASE WHEN ENP.ExEnlazadoPri<>'' THEN ENP.ExEnlazadoPri else ENS.ExEnlazadoSec END, --NombreExpedientesEnlazados,
		'|'+CASE WHEN EE.cantEnlaces>0 THEN '1' ELSE '0' END, --EsPrincipalEnlace, --Tramite.funEsPrincipalEnlace(E.IdExpediente)EsPrincipalEnlace,
		'|'+OID.CatalogoTipoOrigen, --Tramite.fnObtenerOrigenInicialDocumento(E.IdExpediente) CatalogoTipoOrigen,
		'|'+convert(varchar,E.IdExpediente),
		'|'+convert(varchar,E.ExpedienteConfidencial),
		'|'+E.NTFechaExpediente,
		'|'+E.HoraExpediente,
		'|'+convert(varchar,E.IdCatalogoTipoPrioridad),
		'|'+COALESCE(CTP.Descripcion,''), --CatalogoTipoPrioridad,
		'|'+COALESCE(CTT.Descripcion,''), --CatalogoTipoTramite,
		'|'+COALESCE(CTT.Detalle,''), --ColorCatalogoTipoTramite,
		'|'+US.Logueo,
		'|'+COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),'sinfotoH.jpg'), --RutaFotoPersona,
		'|'+UPPER(replace(E.AsuntoExpediente,'|',' ')), --AsuntoExpediente,
		'|'+convert(varchar,COALESCE(E.NumeroFoliosExpediente,0)), --NumeroFoliosExpediente,
		'|'+COALESCE(replace(E.ObservacionesExpediente,'|',' '),''), --ObservacionesExpediente,
		'|'+CONCAT(E.NTFechaExpediente ,' ', E.HoraExpediente), --Fecha,
		'|'+CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT('000000'+CONVERT(VARCHAR,E.NumeroExpediente),6),'-', E.IdPeriodo), --NombreExpediente,
		'|'+CASE WHEN COALESCE(E.NombreCompletoCreador,'')<>'' THEN COALESCE(E.NombreCompletoCreador,'') ELSE PE.NombreCompleto END, --NombreCompletoCreador,
		'|'+convert(varchar,E.NumeroExpediente),
		'|'+convert(varchar,COALESCE(ES.IdExpedienteSeguimiento,0)), --IdExpedienteSeguimiento,
		--Tramite.funObtenerFechaMovimientoEnExpediente(E.IdExpediente,@vIdAreaJefe,@pIdCatalogoSituacionMovimientoDestino) FechaMovimiento
		'|'+isnull(FORMAT(tE.FechaMovimiento, 'dd/MM/yyyy HH:mm'),'') --'|'+convert(var
char,tE.FechaMovimiento,21)
	FROM
	Tramite.Expediente E WITH (NOLOCK)
	INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1  AND COALESCE(E.ExpedienteAnulado,0)=0
	INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
	INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
	LEFT JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK) ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdCargo=0 AND ES.IdPersona=0 AND ES.IdArea=@pIdArea
	LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
	LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
	CROSS APPLY(
				SELECT IdExpediente,FechaMovimiento,EsParaAnular,DiasPendiente,NombrePersonaOrigen,NumeroDocumento,IdExpedienteDocumento
				FROM @vTablaExpediente tE
				where tE.IdExpediente=E.IdExpediente and E.EstadoAuditoria=1
				)tE
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
	CROSS APPLY(
				select isnull((select STUFF((
				SELECT distinct '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
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
				SELECT distinct '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
				CONCAT(SD1.AbreviaturaSerieDocumentalExpediente,RIGHT(CONCAT('000000',E1.NumeroExpediente),6), '-', E1.IdPeriodo)
				+'</div>'
				FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
				INNER JOIN Tramite.Expediente e1 WITH (NOLOCK) ON EE.IdExpediente=E1.IdExpediente AND E1.EstadoAuditoria=1 AND E1.ExpedienteAnulado=0
				INNER JOIN Tramite.SerieDocumentalExpediente SD1 ON SD1.IdSerieDocumentalExpediente=E1.IdSerieDocumentalExpediente and EE.EstadoAuditoria=1
				WHERE EE.IdExpedienteSecundario=E.IdExpediente
				FOR XML PATH('')), 1, 0, '')),'') ExEnlazadoSec
				) ENS
	ORDER BY tE.FechaMovimiento DESC
	OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
	FETCH NEXT @pDimensionPagina ROWS ONLY
	FOR XML PATH('')), 1, 1, ''))
END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteJefaturaPorRecibir',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVE
RITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
