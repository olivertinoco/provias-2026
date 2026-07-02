
-- CREATE PROCEDURE Tramite.paListarPendienteFirmaDigitalJefaturaV2_arq
--     @pIdArea               INT,
--     @pIdUsuarioAuditoria   INT,
--     @pCampoOrdenado        VARCHAR(50),
--     @pTipoOrdenacion       VARCHAR(4),
--     @pNumeroPagina         INT,
--     @pDimensionPagina      INT,
--     @pBusquedaGeneral      VARCHAR(20)
-- AS
-- BEGIN
--   SET NOCOUNT ON;
--   BEGIN TRY

SET LANGUAGE SPANISH;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE
    @pIdArea             INT,
    @pIdUsuarioAuditoria INT,
    @pCampoOrdenado      VARCHAR(50),
    @pTipoOrdenacion     VARCHAR(4),
    @pNumeroPagina       INT,
    @pDimensionPagina    INT,
    @pBusquedaGeneral    VARCHAR(20);

SELECT @pIdArea = 30, @pIdUsuarioAuditoria = 53721, @pCampoOrdenado = NULL,
       @pTipoOrdenacion = NULL, @pNumeroPagina = 1, @pDimensionPagina = 10,
       @pBusquedaGeneral = NULL;


CREATE TABLE #tmp001_expedienteFirma (
    IdExpediente                          INT,
    IdExpedienteDocumento                 INT,
    AbreviaturaSerieDocumentalExpediente  VARCHAR(10),
    NumeroExpediente                      INT,
    IdPeriodo                             INT,
    NumeroDocumento                       VARCHAR(200),
    NFechaDocumento                       VARCHAR(10),
    AsuntoDocumento                       VARCHAR(8000),
    NumeroFoliosDocumento                 INT,
    RutaArchivoDocumento                  VARCHAR(150),
    ObservacionesDocumento                VARCHAR(4000),
    IdExpedienteDocumentoFirmante         INT,
    PosicionX                             INT,
    PosicionY                             INT,
    EsMiDocumento                         INT,
    IdCatalogoTipoFirmante                INT,
    TipoFirma                             NVARCHAR(MAX),
    EsLiberado                            INT,
    AreaEmisor                            VARCHAR(500),
    PersonaEmisor                         VARCHAR(400),
    FechaCreacionAuditoria                DATETIME
);

CREATE TABLE #CargosJefatura (IdCargo INT PRIMARY KEY);
INSERT INTO #CargosJefatura (IdCargo) SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo IN (32, 33, 34);

DECLARE @vSql              NVARCHAR(MAX),
        @vIdPeriodo        INT = 2022,
        @vAnno             INT = YEAR(GETDATE()),
        @vItera            INT = 0,
        @vNuevoPeriodo     INT,
        @vSuf              NVARCHAR(20);

DECLARE @vTotalItera INT = @vAnno - @vIdPeriodo + 1;

WHILE (@vItera < @vTotalItera)
BEGIN
    select @vSql = ''
    SELECT @vNuevoPeriodo = @vIdPeriodo + @vItera;
    SELECT @vSuf = CASE WHEN @vNuevoPeriodo = @vAnno THEN N'' ELSE CONCAT(N'_historico_', @vNuevoPeriodo) END;

    select @vSql = N'
    INSERT INTO #tmp001_expedienteFirma SELECT E.IdExpediente,ED.IdExpedienteDocumento,SD.AbreviaturaSerieDocumentalExpediente,E.NumeroExpediente,E.IdPeriodo,ED.NumeroDocumento,ED.NFechaDocumento,ED.AsuntoDocumento,ED.NumeroFoliosDocumento,ED.RutaArchivoDocumento,ED.ObservacionesDocumento,EDF.IdExpedienteDocumentoFirmante,EDF.PosicionX,EDF.PosicionY,
    CASE WHEN ED.IdAreaEmisor = @pIdArea AND ED.IdEmpresaEmisor = 2 AND EXISTS (SELECT 1 FROM #CargosJefatura CJ WHERE CJ.IdCargo = ED.IdCargoEmisor) THEN 1 ELSE 0 END AS EsMiDocumento,EDF.IdCatalogoTipoFirmante,CONCAT(FP.TotalPendientes, N''¦'', FP.Nombres) AS TipoFirma,CASE WHEN ED.IdUsuarioEnProcesoFirma = @pIdUsuarioAuditoria AND ED.EnProcesoFirma = 1 THEN 1 ELSE 0 END AS EsLiberado,A.NombreArea AS AreaEmisor,P.NombreCompleto AS PersonaEmisor,ED.FechaCreacionAuditoria
    FROM Tramite.Expediente' + @vSuf + N' E INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente = E.IdSerieDocumentalExpediente INNER JOIN Tramite.ExpedienteDocumento' + @vSuf + N' ED ON ED.IdExpediente = E.IdExpediente INNER JOIN Tramite.ExpedienteDocumentoFirmante' + @vSuf + N' EDF ON  EDF.IdExpedienteDocumento = ED.IdExpedienteDocumento AND EDF.EstadoAuditoria = 1 AND EDF.FlagFirmado = 0 AND EDF.IdArea = @pIdArea
    AND EXISTS (SELECT 1 FROM #CargosJefatura CJ WHERE CJ.IdCargo = EDF.IdCargo) INNER JOIN General.Area A ON A.IdArea = ED.IdAreaEmisor INNER JOIN General.Persona P ON P.IdPersona = ED.IdPersonaEmisor CROSS APPLY (SELECT COUNT(*) AS TotalPendientes, STRING_AGG(COALESCE(NP.NombreCompleto, N''''), N''¬'') AS Nombres
    FROM Tramite.ExpedienteDocumentoFirmante' + @vSuf + N' F LEFT JOIN RecursoHumano.EmpleadoPerfil EP2 ON EP2.IdEmpleadoPerfil = F.IdEmpleadoPerfilFirmante LEFT JOIN General.Persona NP ON NP.IdPersona = EP2.IdPersona WHERE F.IdExpedienteDocumento = ED.IdExpedienteDocumento AND F.EstadoAuditoria = 1 AND F.FlagFirmado = 0) FP
    WHERE E.ExpedienteAnulado = 0 AND E.EstadoAuditoria = 1 AND ED.EstadoAuditoria = 1 AND ED.FgEnEsperaFirmaDigital = 1 AND ED.FlagParaDespacho = 1 AND ED.FgEsObligatorioFirmaDigital = 1 AND(@pBusquedaGeneral IS NULL OR @pBusquedaGeneral = N'''' OR CONCAT(SD.AbreviaturaSerieDocumentalExpediente,RIGHT(1000000 + E.NumeroExpediente, 6), ''-'', E.IdPeriodo) LIKE N''%'' + @pBusquedaGeneral + N''%'')
    OPTION (RECOMPILE);';

    EXEC sys.sp_executesql
        @vSql,
        N'@pIdArea INT, @pIdUsuarioAuditoria INT, @pBusquedaGeneral VARCHAR(20)',
        @pIdArea = @pIdArea,
        @pIdUsuarioAuditoria = @pIdUsuarioAuditoria,
        @pBusquedaGeneral = @pBusquedaGeneral;

    SELECT @vItera += 1;
END;

SELECT * FROM #tmp001_expedienteFirma;
