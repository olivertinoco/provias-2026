CREATE OR ALTER PROCEDURE Tramite.paListarPendienteFirmaDigitalEspecialistaV1_arq
	@pIdArea int,
	@pIdCargo int,
	@pIdPersona int,
	@pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(20)
AS
BEGIN
BEGIN TRY
SET LANGUAGE SPANISH
SET NOCOUNT ON
SET TRAN ISOLATION LEVEL READ UNCOMMITTED

create table #tmp001_expedienteFirmadoEsp(
    IdExpediente int,
    IdExpedienteDocumento int,
    IdExpedienteDocumentoFirmante int,
    NombreExpediente varchar(29),
    NumeroDocumento varchar(200),
    NFechaDocumento varchar(10),
    AsuntoDocumento varchar(8000),
    NumeroFoliosDocumento int,
    RutaArchivoDocumento varchar(150),
    ObservacionesDocumento varchar(4000),
    PosicionX int,
    PosicionY int,
    TipoFirma varchar(11),
    EsLiberado int,
    ExpedienteBloqueado varchar(1),
    PersonaVisualiza varchar(1),
)

    Declare @vIdPeriodo int = 2022
    declare @vAnno int = year(getdate()), @vItera int = 0, @vNuevoPeriodo int
	declare @vTotalItera int = @vAnno - @vIdPeriodo + 1
	declare @vcExpedienteRpta Nvarchar(4000) = ''
    DECLARE @Consulta Nvarchar(max)='', @Filtros varchar(max)=''
	IF COALESCE(@pBusquedaGeneral,'')<>''
	SET @Filtros ='AND (CONCAT(SD.AbreviaturaSerieDocumentalExpediente,RIGHT(1000000+E.NumeroExpediente,6), ''-'', E.IdPeriodo) LIKE ''%'+@pBusquedaGeneral +'%'')'

while(@vItera < @vTotalItera)begin
    select @Consulta = ''
    select @vNuevoPeriodo = @vIdPeriodo + @vItera
    SELECT @vcExpedienteRpta = CASE WHEN @vNuevoPeriodo = @vAnno THEN N'' ELSE CONCAT(N'_historico_', @vNuevoPeriodo) END;

	SET @Consulta= N'\
	insert into #tmp001_expedienteFirmadoEsp SELECT E.IdExpediente,
	ED.IdExpedienteDocumento,
	EDF.IdExpedienteDocumentoFirmante,
	CONCAT(SD.AbreviaturaSerieDocumentalExpediente, RIGHT(1000000+E.NumeroExpediente,6), ''-'', E.IdPeriodo) NombreExpediente,
	ED.NumeroDocumento,
	ED.NFechaDocumento,
	ED.AsuntoDocumento,
	COALESCE(ED.NumeroFoliosDocumento,1)NumeroFoliosDocumento,
	ED.RutaArchivoDocumento,
	COALESCE(ED.ObservacionesDocumento,'''') ObservacionesDocumento,
	COALESCE(EDF.PosicionX,0)PosicionX,
	COALESCE(EDF.PosicionY,0)PosicionY,
	CASE EDF.IdCatalogoTipoFirmante WHEN 296 THEN ''FIRMAR'' ELSE ''VISTO BUENO'' END TipoFirma,
	(SELECT COUNT(IdExpedienteDocumento) FROM Tramite.ExpedienteDocumento'+@vcExpedienteRpta+N' WHERE IdUsuarioEnProcesoFirma =@pIdUsuarioAuditoria AND EnProcesoFirma=1 AND IdExpedienteDocumento=ED.IdExpedienteDocumento AND EstadoAuditoria=1) EsLiberado,
	isnull(case when EB.FechaHoraBloquea is null then  ''0'' else case when EB.FechaHoraBloquea<=ED.FechaCreacionAuditoria then ''1'' else ''0'' end end,''0'') ExpedienteBloqueado,isnull(EB1.PersonaVisualiza,''0'') PersonaVisualiza
	FROM Tramite.Expediente'+@vcExpedienteRpta+N' E
	INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente	AND E.ExpedienteAnulado=0
	INNER JOIN Tramite.ExpedienteDocumento'+@vcExpedienteRpta+N' ED ON ED.IdExpediente=E.IdExpediente  and e.EstadoAuditoria=1 AND ED.EstadoAuditoria=1 AND ED.FgEnEsperaFirmaDigital=1
	INNER JOIN Tramite.ExpedienteDocumentoFirmante'+@vcExpedienteRpta+N' EDF ON ED.IdExpedienteDocumento=EDF.IdExpedienteDocumento AND EDF.EstadoAuditoria=1 AND EDF.IdArea=@pIdArea AND EDF.IdCargo=@pIdCargo AND EDF.IdPersona=@pIdPersona
	OUTER APPLY(
		select EB.IdExpedienteBloqueado,EB.FechaHoraBloquea
		from Tramite.ExpedienteBloqueado EB
		where ED.IdExpediente=EB.IdExpediente and EB.EstadoAuditoria=1 and EB.EstadoBloqueo=1
	)EB
	OUTER APPLY(
		select ''1'' PersonaVisualiza
		from Tramite.ExpedienteBloqueadoPersonaVisualiza EBPV
		inner join Seguridad.Usuario U on EBPV.IdPersonaVisualiza=U.IdPersona and U.IdUsuario=@pIdUsuarioAuditoria
		where EBPV.IdExpedienteBloqueado = EB.IdExpedienteBloqueado and EBPV.EstadoAuditoria=1
	)EB1
	WHERE EDF.FlagFirmado=0 AND FgEsObligatorioFirmaDigital=1 '
	+@Filtros

	EXECUTE sp_executesql @Consulta, N'@pIdUsuarioAuditoria int, @pIdArea int, @pIdCargo int,@pIdPersona int',
	@pIdUsuarioAuditoria = @pIdUsuarioAuditoria, @pIdArea = @pIdArea, @pIdCargo = @pIdCargo, @pIdPersona = @pIdPersona

	select @vItera+=1
end

	select*from #tmp001_expedienteFirmadoEsp
	ORDER BY IdExpedienteDocumento DESC
    OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
    FETCH NEXT @pDimensionPagina ROWS ONLY

	select count(1) TotalRegistros from #tmp001_expedienteFirmadoEsp

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() ,
	@ERROR_PROCEDURE='Tramite.paListarPendienteFirmaDigitalEspecialistaV1_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE ,@pIdUsuarioAuditoria
END CATCH
END
GO


-- exec Tramite.paListarPendienteFirmaDigitalEspecialistaV1_arq
-- @pIdArea= 79,
-- @pIdCargo= 272,
-- @pIdPersona= 1059,
-- @pIdUsuarioAuditoria= 1059,
-- @pCampoOrdenado= null,
-- @pTipoOrdenacion= null,
-- @pNumeroPagina= 1,
-- @pDimensionPagina= 10,
-- @pBusquedaGeneral= NULL


-- exec bd_sgd_arq.Tramite.paListarPendienteFirmaDigitalEspecialistaV1
-- @pIdArea= 79,
-- @pIdCargo= 272,
-- @pIdPersona= 1059,
-- @pIdUsuarioAuditoria= 1059,
-- @pCampoOrdenado= null,
-- @pTipoOrdenacion= null,
-- @pNumeroPagina= 1,
-- @pDimensionPagina= 10,
-- @pBusquedaGeneral= NULL
