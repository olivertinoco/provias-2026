-- =========================
-- ME QUEDO CON EL 8.6 FINAL
-- =========================
CREATE OR ALTER PROCEDURE Tramite.paListarExpedientePendienteEspecialistaV7_new
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
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(100),
	@pFlgBusqueda INT
AS
BEGIN
	SET NOCOUNT ON;                                        -- [MOD 1]
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;      -- [MOD 3]

	BEGIN TRY

		DECLARE @vIdCargo int=0, @vIdArea int=0, @vIdEmpresa int=0,
			@iRegistroTotal Int, @iPaginaRegInicio Int, @iPaginaRegFinal Int

		SELECT @vIdCargo=EP.IdCargo,
			@vIdArea=EP.IdArea,
			@vIdEmpresa=ES.IdEmpresa
		FROM RecursoHumano.EmpleadoPerfil EP
			INNER JOIN General.EmpresaSede ES  ON ES.IdEmpresaSede=EP.IdEmpresaSede
		where EP.IdEmpleadoPerfil=@pIdEmpleadoPerfil AND EP.EstadoAuditoria=1 AND EP.Activo=1

		SET LANGUAGE 'SPANISH'
		Create Table #vTablaExpediente(IdExpediente BigInt, FechaMovimiento DATETIME, eNroOrden Int)

		IF (ISNUMERIC(@pBusquedaGeneral)=1 AND CAST(@pBusquedaGeneral as VARCHAR(5)) not LIKE '%.%') OR Isnull(@pBusquedaGeneral, '')=''
		BEGIN
			IF Isnull(@pBusquedaGeneral, '') <> ''
			Begin
				INSERT INTO #vTablaExpediente(IdExpediente, FechaMovimiento, eNroOrden)
				SELECT
					SE.IdExpediente,
					SE.FechaMovimiento,
					Row_Number() Over(Order By SE.FechaMovimiento DESC) As eNroOrden
				FROM
					(
						SELECT E.IdExpediente,
							MAX(CONVERT(DATETIME,edod.FechaDestinoEnvia +' ' + edod.HoraDestinoEnvia)) FechaMovimiento
						FROM
							Tramite.Expediente E
							INNER JOIN Tramite.ExpedienteDocumento ED  ON  E.IdExpediente=ED.IdExpediente AND ED.EstadoAuditoria=E.EstadoAuditoria
							INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO  ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=E.EstadoAuditoria
							INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD  ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria=E.EstadoAuditoria
						WHERE
							E.EstadoAuditoria = 1
							AND E.ExpedienteAnulado=0
							And EDOD.IdPersonaDestino=@pIdPersona
							AND EDOD.IdAreaDestino=@vIdArea
							AND EDOD.IdCargoDestino=@vIdCargo
							AND EDOD.IdEmpresaDestino=@vIdEmpresa
							AND ED.FgEnEsperaFirmaDigital=0
							AND EDOD.IdCatalogoSituacionMovimientoDestino=@pIdCatalogoSituacionMovimientoDestino
							AND EDOD.FechaDestino BETWEEN  case when @pConFiltroFecha =1 then @pFechaInicio else EDOD.FechaDestino end
														And	case when @pConFiltroFecha =1 then @pFechaFin else EDOD.FechaDestino end
							AND (E.NumeroExpediente = @pBusquedaGeneral)
						GROUP BY E.IdExpediente
					) SE
				OPTION (MAXDOP 2)
			END
			ELSE
			BEGIN
				INSERT INTO #vTablaExpediente(IdExpediente, FechaMovimiento, eNroOrden)
				SELECT
					SE.IdExpediente,
					SE.FechaMovimiento,
					Row_Number() Over(Order By SE.FechaMovimiento DESC) As eNroOrden
				FROM
					(
						SELECT E.IdExpediente,
							MAX(CONVERT(DATETIME,edod.FechaDestinoEnvia +' ' + edod.HoraDestinoEnvia)) FechaMovimiento
						FROM
							Tramite.Expediente E
							INNER JOIN Tramite.ExpedienteDocumento ED  ON  E.IdExpediente=ED.IdExpediente AND ED.EstadoAuditoria=E.EstadoAuditoria
							INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO  ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=E.EstadoAuditoria
							INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD  ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDOD.EstadoAuditoria=E.EstadoAuditoria
						WHERE
							E.EstadoAuditoria = 1
							AND E.ExpedienteAnulado=0
							And EDOD.IdPersonaDestino=@pIdPersona
							AND EDOD.IdAreaDestino=@vIdArea
							AND EDOD.IdCargoDestino=@vIdCargo
							AND EDOD.IdEmpresaDestino=@vIdEmpresa
							AND ED.FgEnEsperaFirmaDigital=0
							AND EDOD.IdCatalogoSituacionMovimientoDestino=@pIdCatalogoSituacionMovimientoDestino
							AND EDOD.FechaDestino BETWEEN  case when @pConFiltroFecha =1 then @pFechaInicio else EDOD.FechaDestino end
														And	case when @pConFiltroFecha =1 then @pFechaFin else EDOD.FechaDestino end
						GROUP BY E.IdExpediente
					) SE
				OPTION (MAXDOP 2)
			END
		END

		--Calculando Paginación
		Begin
			Set @iRegistroTotal = (Select Count(1) From #vTablaExpediente)
			--
			SELECT @iPaginaRegInicio = c.iStartRow,
				@iPaginaRegFinal = c.iEndrow
			FROM General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c
		End
		--
		SELECT
			Tramite.funParaAnularEspecialista(E.IdExpediente,@pIdPersona,@vIdEmpresa,@vIdArea,@vIdCargo) EsParaAnular,
			Tramite.funObtenerDiasPendienteEspecislista(E.IdExpediente,@pIdPersona, @vIdEmpresa,@vIdArea,@vIdCargo,@pIdCatalogoSituacionMovimientoDestino) DiasPendiente,
			'' NombrePersonaOrigen,
			Tramite.funObtenerNumeroDocumentoEnExpedienteEspecialistaV1(E.IdExpediente,@vIdArea,@vIdCargo,@pIdPersona,@pIdCatalogoSituacionMovimientoDestino) NumeroDocumento,
			Tramite.funObtenerIdExpedienteDocumentoEnExpedienteEspecialista(E.IdExpediente,@vIdArea,@vIdCargo,@pIdPersona,@pIdCatalogoSituacionMovimientoDestino) IdExpedienteDocumento,
			Tramite.funObtenerExpedientesEnlazados(E.IdExpediente) NombreExpedientesEnlazados,
			Tramite.funEsPrincipalEnlace(E.IdExpediente)EsPrincipalEnlace,
			Tramite.fnObtenerOrigenInicialDocumento(E.IdExpediente) CatalogoTipoOrigen,
			E.IdExpediente,
			E.ExpedienteConfidencial,
			E.NTFechaExpediente,
			E.HoraExpediente,
			E.IdCatalogoTipoPrioridad,
			CTP.Descripcion CatalogoTipoPrioridad,
			COALESCE(CTT.Descripcion,'') CatalogoTipoTramite,
			COALESCE(CTT.Detalle,'') ColorCatalogoTipoTramite,
			US.Logueo,
			case when COALESCE(SFU.RutaArchivoFoto,'') ='' then CASE WHEN COALESCE(PE.Sexo,0)=0 then 'sinfotoH.jpg' else 'sinfotoM.jpg' end else SFU.RutaArchivoFoto end As RutaFotoPersona,
			E.AsuntoExpediente,
			E.NumeroFoliosExpediente,
			COALESCE(E.ObservacionesExpediente,'') ObservacionesExpediente,
			CONCAT(E.NTFechaExpediente ,' ', E.HoraExpediente) Fecha,
			E.NombreExpediente,
			CASE WHEN COALESCE(E.NombreCompletoCreador,'')<>'' THEN COALESCE(E.NombreCompletoCreador,'') ELSE PE.NombreCompleto END NombreCompletoCreador,
			E.NumeroExpediente,
			COALESCE(ES.IdExpedienteSeguimiento,0)IdExpedienteSeguimiento,
			EX.FechaMovimiento
		FROM
			Tramite.Expediente E
			INNER JOIN #vTablaExpediente EX ON EX.IDEXPEDIENTE=E.IDEXPEDIENTE
			INNER JOIN Seguridad.Usuario US  ON US.IdUsuario=E.IdUsuarioCreacionAuditoria           -- [MOD] NOLOCK
			INNER JOIN Tramite.Catalogo CTP  ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad            -- [MOD] NOLOCK
			INNER JOIN Tramite.Catalogo CTT  ON CTT.IdCatalogo=E.IdCatalogoTipoTramite              -- [MOD] NOLOCK
			LEFT JOIN General.Persona PE  ON PE.IdPersona=E.IdPersonaCreador                        -- [MOD] NOLOCK
			LEFT  JOIN Tramite.ExpedienteSeguimiento ES  ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdEmpresa=@vIdEmpresa AND ES.IdCargo=@vIdCargo AND ES.IdPersona=@pIdPersona AND ES.IdArea=@vIdArea
			OUTER APPLY(
			    SELECT TOP 1 FU.RutaArchivoFoto
                FROM Seguridad.Usuario FU                                                           -- [MOD] NOLOCK
                WHERE FU.IdPersona = PE.IdPersona And FU.EstadoAuditoria=1 AND FU.Bloqueado=0
                ORDER BY FU.RutaArchivoFoto DESC
            ) SFU
		WHERE EX.eNroOrden Between @iPaginaRegInicio And @iPaginaRegFinal
		ORDER BY EX.eNroOrden ASC


		SELECT @iRegistroTotal


END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() ,
	@ERROR_PROCEDURE='Tramite.paListarExpedientePendienteEspecialistaV7_new',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
END
GO


-- set statistics io on
-- set statistics time on

-- exec tramite.paListarExpedientePendienteEspecialistaV7
-- 0,'10/03/2026','10/03/2026',0,'10/03/2026','10/03/2026',1309,3158,3,4,0,0,2026,0,0,0,'','','','',0,'','','',26766,NULL,NULL,2,100,NULL,0



-- set statistics io off
-- set statistics time off




-- exec tramite.paListarExpedientePendienteEspecialistaV7_new
-- 0,'10/03/2026','10/03/2026',0,'10/03/2026','10/03/2026',1309,3158,3,4,0,0,2026,0,0,0,'','','','',0,'','','',26766,NULL,NULL,2,100,NULL,0
