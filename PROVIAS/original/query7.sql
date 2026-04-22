CREATE PROCEDURE [Tramite].[paObtenerEstadosExpedientesEspecialista]
	@pIdPersona int,
	@pIdEmpleadoPerfil int,
	@pIdUsuarioAuditoria int
AS
	BEGIN TRY

		declare @vTod int=0
		DECLARE @vIdCargo int=0
		DECLARE @vIdArea int=0
		DECLARE @vIdEmpresa int=0
		SELECT @vIdCargo=EP.IdCargo,@vIdArea=EP.IdArea,@vIdEmpresa=EP.IdEmpresa
		FROM RecursoHumano.visEmpleadoPerfilPersona EP
		WHERE EP.IdEmpleadoPerfil=@pIdEmpleadoPerfil


		SELECT
		0 Res,
		COALESCE(SUM(CASE WHEN X.IdCatalogoSituacionMovimientoDestino=4 THEN 1 ELSE 0 END),0) Rec,
		COALESCE(SUM(CASE WHEN X.IdCatalogoSituacionMovimientoDestino=5 THEN 1 ELSE 0 END),0) Pen,
		0 Dev,
		0 Ree,
		0 Arc,
		0 Env,
		0 Seg,
		0 Mis,
		@vTod Tod
		FROM (
		SELECT DISTINCT EDOD.IdExpediente, EDOD.IdCatalogoSituacionMovimientoDestino FROM
		Tramite.visExpedienteCompleto EDOD
		WHERE EDOD.FgEnEsperaFirmaDigital=0 AND (EDOD.IdPersonaDestino=@pIdPersona)
		AND (EDOD.IdAreaDestino=@vIdArea)
		AND (EDOD.IdCargoDestino=@vIdCargo)
		AND (EDOD.IdEmpresaDestino=@vIdEmpresa)) X



	END TRY
	BEGIN CATCH
			DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
			SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paObtenerEstadosExpedientesEspecialista',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
			EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE,@pIdUsuarioAuditoria
	 END CATCH
