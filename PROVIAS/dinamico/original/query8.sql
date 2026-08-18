ALTER PROCEDURE [Tramite].[paListarExpedientePendienteJefaturaTodos]
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
    DECLARE @vTablaCargos TABLE(Idcargo int)

    INSERT INTO @vTablaCargos SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)

    SELECT @vIdAreaJefe=IdArea,@vIdEmpresaJefe=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea
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

   SELECT
   convert(bit,0) EsParaAnular,
   0 DiasPendiente,
   ''NombrePersonaOrigen,
   '' NumeroDocumento,
   0 IdExpedienteDocumento,
   Tramite.funObtenerExpedientesEnlazados(E.IdExpediente) NombreExpedientesEnlazados,
   Tramite.funEsPrincipalEnlace(E.IdExpediente)EsPrincipalEnlace,
   Tramite.fnObtenerOrigenInicialDocumento(E.IdExpediente) CatalogoTipoOrigen,
   E.IdExpediente,
   E.ExpedienteConfidencial,
   E.NTFechaExpediente,
   E.HoraExpediente,
   E.IdCatalogoTipoPrioridad,
   COALESCE(CTP.Descripcion,'') CatalogoTipoPrioridad,
   COALESCE(CTT.Descripcion,'') CatalogoTipoTramite,
   COALESCE(CTT.Detalle,'') ColorCatalogoTipoTramite,
   US.Logueo,
   COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(E.IdPersonaCreador),'sinfotoH.jpg') RutaFotoPersona,
   UPPER(E.AsuntoExpediente) AsuntoExpediente,
   COALESCE(E.NumeroFoliosExpediente,0)NumeroFoliosExpediente,
   COALESCE(E.ObservacionesExpediente,'') ObservacionesExpediente,
   CONCAT(E.NTFechaExpediente ,' ', E.HoraExpediente) Fecha,
   CONCAT(SD.AbreviaturaSerieDocumentalExpediente +RIGHT('000000'+CONVERT(VARCHAR,E.NumeroExpediente),6),'-', E.IdPeriodo) NombreExpediente,
   CASE WHEN COALESCE(E.NombreCompletoCreador,'')<>'' THEN COALESCE(E.NombreCompletoCreador,'') ELSE PE.NombreCompleto END NombreCompletoCreador,
   E.NumeroExpediente,
   COALESCE(ES.IdExpedienteSeguimiento, 0 )IdExpedienteSeguimiento,
   NULL FechaMovimiento
   FROM Tramite.Expediente E WITH (NOLOCK)
   INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1 AND COALESCE(E.ExpedienteAnulado,0)=0
   INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
   INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
   LEFT JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK) ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdCargo=0 AND ES.IdPersona=0 AND ES.IdArea=@pIdArea
   LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
   LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
   WHERE E.NumeroExpediente = CASE WHEN ISNUMERIC(@pBusquedaGeneral)=1 THEN @pBusquedaGeneral ELSE 0 END OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0
   ORDER BY IdExpediente DESC
   OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
   FETCH NEXT @pDimensionPagina ROWS ONLY

   SELECT COUNT(*) FROM Tramite.Expediente E WITH (NOLOCK)
   INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria AND E.EstadoAuditoria=1 AND COALESCE(E.ExpedienteAnulado,0)=0
   INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
   INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
   LEFT JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK) ON ES.IdExpediente= E.IdExpediente AND ES.EstadoAuditoria=1 AND ES.IdCargo=0 AND ES.IdPersona=0 AND ES.IdArea=@pIdArea
   LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
   LEFT JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
   WHERE (E.NumeroExpediente =  @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
    @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteJefaturaTodos',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
END
