CREATE OR ALTER PROCEDURE Tramite.paListarPendienteFirmaDigitalJefaturaV2_arq
	@pIdArea int,
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

create table #tmp001_expedienteFirma (
    IdExpediente int,
    IdExpedienteDocumento int,
    AbreviaturaSerieDocumentalExpediente varchar(10) collate database_default,
    NumeroExpediente int,
    IdPeriodo int,
    NumeroDocumento varchar(200) collate database_default,
    NFechaDocumento varchar(10) collate database_default,
    AsuntoDocumento varchar(8000) collate database_default,
    NumeroFoliosDocumento int,
    RutaArchivoDocumento varchar(150) collate database_default,
    ObservacionesDocumento varchar(4000) collate database_default,
    IdExpedienteDocumentoFirmante int,
    PosicionX int,
    PosicionY int,
    EsMiDocumento int,
    IdCatalogoTipoFirmante int,
    TipoFirma nvarchar(max) collate database_default,
    EsLiberado int,
    AreaEmisor varchar(500) collate database_default,
    PersonaEmisor varchar(400) collate database_default,
    FechaCreacionAuditoria datetime
)

    Declare @vSql nvarchar(max)
	Declare @vPeriodo varchar(4), @cta int = 0, @tot int = year(getdate()) - 2022
    while @cta < @tot begin
        select @vSql = '', @vPeriodo = null
        select @vPeriodo = 2022 + @cta

        select @vSql = N'\
        insert into #tmp001_expedienteFirma SELECT E.IdExpediente,ED.IdExpedienteDocumento,SD.AbreviaturaSerieDocumentalExpediente,E.NumeroExpediente,E.IdPeriodo,ED.NumeroDocumento,ED.NFechaDocumento,ED.AsuntoDocumento,ED.NumeroFoliosDocumento,ED.RutaArchivoDocumento,ED.ObservacionesDocumento,EDF.IdExpedienteDocumentoFirmante,EDF.PosicionX,EDF.PosicionY,
        CASE WHEN ED.IdCargoEmisor IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) and ED.IdAreaEmisor=@pIdArea and ED.IdEmpresaEmisor=2 THEN 1 ELSE 0 END EsMiDocumento,EDF.IdCatalogoTipoFirmante,F.FaltaFirma,
        (SELECT COUNT(IdExpedienteDocumento) FROM Tramite.ExpedienteDocumento_historico_'+ @vPeriodo +N' WHERE IdUsuarioEnProcesoFirma =@pIdUsuarioAuditoria AND EnProcesoFirma=1 AND IdExpedienteDocumento=ED.IdExpedienteDocumento AND EstadoAuditoria=1) EsLiberado,A.NombreArea AreaEmisor,P.NombreCompleto PersonaEmisor,ED.FechaCreacionAuditoria
        FROM Tramite.Expediente_historico_'+ @vPeriodo +N' E
        INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente	AND E.ExpedienteAnulado=0
        INNER JOIN Tramite.ExpedienteDocumento_historico_'+ @vPeriodo +N' ED ON ED.IdExpediente=E.IdExpediente  and e.EstadoAuditoria=1 AND ED.EstadoAuditoria=1 AND ED.FgEnEsperaFirmaDigital=1
        INNER JOIN Tramite.ExpedienteDocumentoFirmante_historico_'+ @vPeriodo +N' EDF ON ED.IdExpedienteDocumento=EDF.IdExpedienteDocumento AND EDF.EstadoAuditoria=1 AND EDF.FlagFirmado=0 AND EDF.IdCargo IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) AND EDF.IdArea=@pIdArea
        INNER JOIN General.Area A ON ED.IdAreaEmisor=A.IdArea
        INNER JOIN General.Persona P ON ED.IdPersonaEmisor=p.IdPersona
        CROSS APPLY(select(SELECT convert(varchar,count(*)) FROM Tramite.ExpedienteDocumentoFirmante_historico_'+ @vPeriodo +N' EDF
        WHERE EDF.EstadoAuditoria=1 and EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.FlagFirmado=0)+''¦''+
        (select STUFF((SELECT ''¬''+COALESCE(Ep.NombreCompleto,'''''''')
        FROM Tramite.ExpedienteDocumentoFirmante_historico_'+ @vPeriodo +N' EDF
        INNER JOIN RecursoHumano.visEmpleadoPerfilPersona EP ON EP.IdEmpleadoPerfil=EDF.IdEmpleadoPerfilFirmante
        WHERE EDF.EstadoAuditoria=1 and EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.FlagFirmado=0
        FOR XML PATH('''')), 1, 1, '''')) FaltaFirma
        )F WHERE ED.FlagParaDespacho=1 AND ED.FgEsObligatorioFirmaDigital=1 AND CONCAT(SD.AbreviaturaSerieDocumentalExpediente,RIGHT(1000000+E.NumeroExpediente,6), ''-'', E.IdPeriodo) LIKE  case when COALESCE(@pBusquedaGeneral,'''')<>'''' THEN ''%''+@pBusquedaGeneral +''%'' ELSE ''%'' END'

        exec sp_executesql @vSql, N'@pIdArea int,@pIdUsuarioAuditoria int,@pBusquedaGeneral varchar(20)',
        @pIdArea = @pIdArea, @pIdUsuarioAuditoria = @pIdUsuarioAuditoria, @pBusquedaGeneral = @pBusquedaGeneral

        select @cta+=1
    end

select
    t.IdExpediente,
    t.IdExpedienteDocumento,
    CONCAT(t.AbreviaturaSerieDocumentalExpediente,RIGHT(1000000+t.NumeroExpediente,6), '-', t.IdPeriodo) NombreExpediente,
    t.NumeroDocumento,
    t.NFechaDocumento,
    t.AsuntoDocumento,
    isnull(t.NumeroFoliosDocumento, 1) NumeroFoliosDocumento,
    t.RutaArchivoDocumento,
    isnull(t.ObservacionesDocumento, '') ObservacionesDocumento,
    t.IdExpedienteDocumentoFirmante,
    isnull(t.PosicionX, 0) PosicionX,
    isnull(t.PosicionY, 0) PosicionY,
    t.EsMiDocumento,
    CASE t.IdCatalogoTipoFirmante WHEN 296 THEN 'FIRMAR' ELSE 'VISTO BUENO' END+'¦'+t.TipoFirma TipoFirma,
    t.EsLiberado,
    t.AreaEmisor,
    t.PersonaEmisor,
    isnull(case when EB.FechaHoraBloquea is null then  '0' else
    case when EB.FechaHoraBloquea<=t.FechaCreacionAuditoria then '1' else '0' end end,'0') ExpedienteBloqueado,
    isnull(EB1.PersonaVisualiza,'0') PersonaVisualiza
from #tmp001_expedienteFirma t
OUTER APPLY(
	select EB.IdExpedienteBloqueado,EB.FechaHoraBloquea
	from Tramite.ExpedienteBloqueado EB
	where EB.IdExpediente = t.IdExpediente and EB.EstadoAuditoria=1 and EB.EstadoBloqueo=1
)EB
OUTER APPLY(
	select '1' PersonaVisualiza
	from Tramite.ExpedienteBloqueadoPersonaVisualiza EBPV
	inner join Seguridad.Usuario U on EBPV.IdPersonaVisualiza=U.IdPersona and U.IdUsuario=@pIdUsuarioAuditoria
	where EB.IdExpedienteBloqueado=EBPV.IdExpedienteBloqueado and EBPV.EstadoAuditoria=1
)EB1
ORDER BY t.IdExpedienteDocumento DESC
OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
FETCH NEXT @pDimensionPagina ROWS ONLY

select count(1) from #tmp001_expedienteFirma

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paListarPendienteFirmaDigitalJefaturaV2_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE ,@pIdUsuarioAuditoria
END CATCH
END
GO


EXEC Tramite.paListarPendienteFirmaDigitalJefaturaV2_arq
@pIdArea = 30, @pIdUsuarioAuditoria = 53721, @pCampoOrdenado = NULL,
@pTipoOrdenacion = NULL, @pNumeroPagina = 1, @pDimensionPagina = 10, @pBusquedaGeneral = NULL;


-- EXEC BD_SGD_ARQ.Tramite.paListarPendienteFirmaDigitalJefaturaV2
-- @pIdArea = 30, @pIdUsuarioAuditoria = 53721, @pCampoOrdenado = NULL,
-- @pTipoOrdenacion = NULL, @pNumeroPagina = 1, @pDimensionPagina = 10, @pBusquedaGeneral = NULL;


-- SELECT
-- @pIdArea = 30,
-- @pIdUsuarioAuditoria = 53721,
-- @pCampoOrdenado = NULL,
-- @pTipoOrdenacion = NULL,
-- @pNumeroPagina = 1,
-- @pDimensionPagina = 10,
-- @pBusquedaGeneral = NULL
