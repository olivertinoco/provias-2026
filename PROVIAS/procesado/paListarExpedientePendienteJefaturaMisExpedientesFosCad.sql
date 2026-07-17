ALTER PROCEDURE [Tramite].[paListarExpedientePendienteJefaturaMisExpedientesFosCad]
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
		DECLARE @vIdAreaJefe int=0
		DECLARE @vIdEmpresaJefe int=0
		DECLARE @vIdCargoJefe int=0

		SELECT @vIdAreaJefe=IdArea,@vIdEmpresaJefe=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea
		SET LANGUAGE 'SPANISH'
		DECLARE @vTablaExpediente TABLE(IdExpediente int)

			IF ISNUMERIC(@pBusquedaGeneral)=1 OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=''
			BEGIN
				--INSERT INTO @vTablaExpediente
				--SELECT EDOD.IdExpediente FROM
				--Tramite.visExpedienteCompleto EDOD
				--WHERE
				--EDOD.IdAreaOrigen=@vIdAreaJefe
				--AND EDOD.IdCargoOrigen IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
				--AND EDOD.IdEmpresaOrigen=@vIdEmpresaJefe
				--AND  CONVERT(DATETIME,eDOD.NTFechaExpediente) BETWEEN  case when @pConFiltroFecha =1 then @pFechaInicio else EDOD.NTFechaExpediente end and case when @pConFiltroFecha =1 then @pFechaFin else EDOD.NTFechaExpediente end
				--AND (EDOD.NumeroExpediente =  @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)
				--GROUP BY IdExpediente
				--UNION
				--SELECT EDOD.IdExpediente FROM
				--Tramite.visExpedienteCompleto EDOD
				--WHERE
				--EDOD.IdAreaDestino=@vIdAreaJefe
				--AND EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
				--AND EDOD.IdEmpresaDestino=@vIdEmpresaJefe
				--AND  CONVERT(DATETIME,eDOD.NTFechaExpediente) BETWEEN  case when @pConFiltroFecha =1 then @pFechaInicio else EDOD.NTFechaExpediente end and case when @pConFiltroFecha =1 then @pFechaFin else EDOD.NTFechaExpediente end
				--AND (EDOD.NumeroExpediente =  @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)
				--GROUP BY IdExpediente
				--;with exp_cte as
				--(
				insert into @vTablaExpediente
				select distinct IdExpediente from(
				select IdExpediente from(select top 100 E.IdExpediente
				FROM
				Tramite.Expediente E WITH (NOLOCK)
				--INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente AND E.EstadoAuditoria=1
				INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK) ON  E.IdExpediente=ED.IdExpediente AND ED.EstadoAuditoria=1 AND COALESCE(E.ExpedienteAnulado,0)=0
				INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1
				where edo.IdAreaOrigen=@vIdAreaJefe and
				      edo.IdCargoOrigen IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) and
				      EDO.IdempresaOrigen=@vIdEmpresaJefe
					  AND  CONVERT(DATETIME,E.NTFechaExpediente) BETWEEN  case when @pConFiltroFecha =1 then @pFechaInicio else E.NTFechaExpediente end and case when @pConFiltroFecha =1 then @pFechaFin else E.NTFechaExpediente end
					  AND (E.NumeroExpediente =  @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)
					  AND YEAR(EDO.FechaCreacionAuditoria) = @pIdPeriodo
			    group by E.IdExpediente
				order by E.IdExpediente desc)t
				union all
				select IdExpediente from(select top 100 E.IdExpediente
				FROM
				Tramite.Expediente E WITH (NOLOCK)
				--INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente AND E.EstadoAuditoria=1
				INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK) ON  E.IdExpediente=ED.IdExpediente AND ED.EstadoAuditoria=1 AND COALESCE(E.ExpedienteAnulado,0)=0
				INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK) ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1
				INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK) ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria=1
				where EDOD.IdAreaDestino=@vIdAreaJefe and
				 	  EDOD.IdCargoDestino IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) and
				      EDOD.IdEmpresaDestino=@vIdEmpresaJefe
					  AND  CONVERT(DATETIME,E.NTFechaExpediente) BETWEEN  case when @pConFiltroFecha =1 then @pFechaInicio else E.NTFechaExpediente end and case when @pConFiltroFecha =1 then @pFechaFin else E.NTFechaExpediente end
					  AND (E.NumeroExpediente =  @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)
					  AND YEAR(EDOD.FechaCreacionAuditoria) = @pIdPeriodo
				group by E.IdExpediente
				order by E.IdExpediente desc)t)t
				--insert into @vTablaExpediente
				--select TOP 1000 * from exp_cte order by IdExpediente desc
			END

			select
			(SELECT convert(varchar,count(*)) FROM @vTablaExpediente)+'¦'+
			(select STUFF((
			SELECT
				'¬0', --Tramite.funParaAnularJefatura(E.IdExpediente,@pIdArea,@vIdCargoJefe) EsParaAnular,
				'|0', --Tramite.funObtenerDiasPendiente(E.IdExpediente,@vIdAreaJefe,@pIdCatalogoSituacionMovimientoDestino) DiasPendiente,
				'|', --NombrePersonaOrigen,
				'|', --NumeroDocumento,
				'|0', --IdExpedienteDocumento,
				'|'+CASE WHEN ENP.ExEnlazadoPri<>'' THEN ENP.ExEnlazadoPri else ENS.ExEnlazadoSec END, --Tramite.funObtenerExpedientesEnlazados(E.IdExpediente) NombreExpedientesEnlazados,
				'|'+CASE WHEN EEN.cantEnlaces>0 THEN '1' ELSE '0' END, --Tramite.funEsPrincipalEnlace(E.IdExpediente)EsPrincipalEnlace,
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
				'|'+isnull(RFP.RutaFotoPersona,'sinfotoH.jpg'),--COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),'sinfotoH.jpg') RutaFotoPersona,
				'|'+UPPER(replace(E.AsuntoExpediente,'|',' ')), --AsuntoExpediente,
				'|'+convert(varchar,COALESCE(E.NumeroFoliosExpediente,0)), --NumeroFoliosExpediente,
				'|'+COALESCE(replace(E.ObservacionesExpediente,'|',' '),''), --ObservacionesExpediente,
				'|'+CONCAT(E.NTFechaExpediente ,' ', E.HoraExpediente), --Fecha,
				'|'+CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT('000000'+CONVERT(VARCHAR,E.NumeroExpediente),6),'-', E.IdPeriodo), --NombreExpediente,
				'|'+CASE WHEN COALESCE(E.NombreCompletoCreador,'')<>'' THEN COALESCE(E.NombreCompletoCreador,'') ELSE PE.NombreCompleto END, --NombreCompletoCreador,
				'|'+convert(varchar,E.NumeroExpediente),
				'|'+convert(varchar,COALESCE(ES.IdExpedienteSeguimiento,0)), --IdExpedienteSeguimiento,
				'|' --FechaMovimiento
				FROM
				Tramite.Expediente E WITH (NOLOCK)
				INNER JOIN @vTablaExpediente EX ON EX.IDEXPEDIENTE=E.IDEXPEDIENTE
				INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1 AND COALESCE(E.ExpedienteAnulado,0)=0
				INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
				INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
				INNER JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
				LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
				LEFT JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK) ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdCargo=0 AND ES.IdPersona=0 AND ES.IdArea=@pIdArea
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
				OUTER APPLY(
					SELECT top 1 isnull(case when COALESCE(U1.RutaArchivoFoto,'') ='' then CASE WHEN COALESCE(Pr1.Sexo,0)=0 then 'sinfotoH.jpg' else 'sinfotoM.jpg' end else U1.RutaArchivoFoto end,'') RutaFotoPersona
					FROM Seguridad.Usuario U1
					INNER JOIN General.Persona PR1 ON PR1.IdPersona=U1.IdPersona
					WHERE U1.EstadoAuditoria=1 and pr1.IdPersona=E.IdPersonaCreador AND U1.Bloqueado=0
				)RFP
				ORDER BY E.IdExpediente DESC
				OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
				FETCH NEXT @pDimensionPagina ROWS ONLY
				FOR XML PATH('')), 1, 1, ''))


				--SELECT
				--COUNT(*)
				--FROM
				--Tramite.Expediente E WITH (NOLOCK)
				--INNER JOIN @vTablaExpediente EX ON EX.IDEXPEDIENTE=E.IDEXPEDIENTE
				--INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1  AND COALESCE(E.ExpedienteAnulado,0)=0
				--INNER JOIN Tramite.SerieDocumentalExpediente SD WITH (NOLOCK) ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
				--INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
				--INNER JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
				--LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
				--LEFT JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK) ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdCargo=0 AND ES.IdPersona=0 AND ES.IdArea=@pIdArea

	END TRY
	BEGIN CATCH
			DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
			SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteJefaturaMisExpedientes',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
			EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria

	 END CATCH
END
GO
