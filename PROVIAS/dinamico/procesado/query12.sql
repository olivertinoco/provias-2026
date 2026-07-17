CREATE OR ALTER PROCEDURE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq
    @pIdExpediente int,
    @pIdArea int,
    @pIdUsuarioAuditoria int,
    @pCampoOrdenado varchar(50),
    @pTipoOrdenacion varchar(4),
    @pNumeroPagina INT,
    @pDimensionPagina  INT,
    @pBusquedaGeneral varchar(100),
    @pCorrelativoVinculado int,
    @pIdPeriodo int
AS
BEGIN
BEGIN TRY
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET LANGUAGE SPANISH

if @pIdPeriodo = year(getdate())begin
    RAISERROR('El periodo no debe ser el actual o vacio', 10, 1) with nowait;
    return;
end;

create table #tmp001_dato_expediente01 (
    FgEnEsperaFirmaDigital bit,
    EsVinculado bit,
    ExpedienteAnulado bit,
    IdExpediente int,
    IdExpedienteDocumento int,
    IdExpedienteDocumentoOrigen int,
    IdCatalogoSituacionMovimientoDestino int,
    IdCatalogoTipoMovimientoDestino int,
    IdCatalogoTipodevolucion int,
    NumeroDiasAtencionSolicitado int,
    FechaDestinoRecepciona varchar(10) collate database_default,
    HoraDestinoRecepciona varchar(5) collate database_default,
    IdEmpresaOrigen int,
    IdAreaOrigen int,
    IdCargoOrigen int,
    IdEmpresaDestino int,
    IdAreaDestino int,
    IdCargoDestino int,
    IdEmpresaDestinoRecepciona int,
    IdAreaDestinoRecepciona int,
    IdCargoDestinoRecepciona int,
    IdPersonaDestinoRecepciona int,
    IdEmpresaDestinoAtencion int,
    IdAreaDestinoAtencion int,
    IdCargoDestinoAtencion int,
    IdPersonaDestinoAtencion int,
    IdPersonaDestino int,
    IdPersonaOrigen int,
    NombreCompletoOrigen varchar(100) collate database_default,
    NumeroDiasAtencionAceptado int,
    Original bit,
    Copia bit,
    FechaDestino varchar(10) collate database_default,
    HoraDestino varchar(5) collate database_default,
    FechaDestinoEnvia varchar(10) collate database_default,
    HoraDestinoEnvia varchar(5) collate database_default,
    DestinatarioDestino varchar(800) collate database_default,
    ObservacionesDestinatario varchar(4000) collate database_default,
    Acciones varchar(max) collate database_default,
    IdExpedienteDocumentoOrigenDestino int,
    NumeroDocumento varchar(200) collate database_default,
    AsuntoDocumento varchar(8000) collate database_default,
    RutaArchivoDocumento varchar(150) collate database_default,
    FechaArchivado varchar(10) collate database_default,
    HoraArchivado varchar(5) collate database_default,
    Descripciondevolucion varchar(4000) collate database_default,
    EsExtornable int,
    EsInicial int,
    MotivoArchivado varchar(8000) collate database_default,
    CorrelativoVinculado int,
    FgEsObligatorioFirmaDigital bit,
    FlagParaDespacho bit,
    IdExpedienteVirtual int,
    FechaOrigen varchar(10) collate database_default,
    HoraOrigen varchar(5) collate database_default,
    IdCatalogoTipoDocumento int,
    Descripcion varchar(400) collate database_default
)

    DECLARE @Consulta Nvarchar(max)=''
    DECLARE @ConsultaTotal Nvarchar(max)=''
    DECLARE @Filtros varchar(max)=''
    DECLARE @Offset NVARCHAR(MAX)='';
    DECLARE @Fetch NVARCHAR(MAX)='';
    DECLARE @Orden NVARCHAR(MAX)='';
    DECLARE @Parametros NVARCHAR(MAX)='';
	DECLARE @vCondicionVinculado nVARCHAR(200)=''
	DECLARE @vSiPariticipo int=0

	DECLARE @vIdPersonaActual int=0,@vIdCargoJefeEsMio int,@vIdAreaJefeEsMio int,@vIdEmpresaJefeEsMio int
	SELECT @vIdPersonaActual=IdPersona from Seguridad.Usuario where IdUsuario=@pIdUsuarioAuditoria AND EstadoAuditoria=1 AND Bloqueado=0

	DECLARE @vIdTipoFormulario INT=0
	SELECT @vIdTipoFormulario=COUNT(IdTipoFormulario)
	FROM Tramite.PermisoVisualizacionDocumentos
	WHERE EstadoAuditoria=1 and IdPersona=@vIdPersonaActual AND IdTipoFormulario=3 and
	convert(date, GETDATE() )between convert(date,FechaInicioPersmiso) and convert(date,FechaFinPersmiso)

	Declare @vPeriodo varchar(4)=null, @cta int = 0, @tot int = year(getdate()) - 2022

	IF @vIdTipoFormulario>0
	BEGIN
		SET @vSiPariticipo=1
	END ELSE BEGIN
	    IF(SELECT COUNT(1) FROM RecursoHumano.visPersonaJefe WHERE IdPersona = @vIdPersonaActual AND IdArea=@pIdArea)>0
  		BEGIN
      		SELECT @vIdCargoJefeEsMio=IdCargo, @vIdAreaJefeEsMio=IdArea,@vIdEmpresaJefeEsMio=IdEmpresa
      		FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea AND IdPersona = @vIdPersonaActual
            select @vSiPariticipo = 0, @Consulta = null

            select @cta = 0, @vPeriodo = null
            while @cta < @tot begin
                select @vPeriodo = 2022 + @cta

                select @Consulta = N'\
           	    SET @vSiPariticipo += (select COUNT(ED.IdPersonaEmisor)
          		FROM Tramite.ExpedienteDocumento_historico_' + @vPeriodo + N' ED
          		INNER JOIN Tramite.ExpedienteDocumentoOrigen_historico_' + @vPeriodo + N' EDO
          		ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
          		INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_historico_' + @vPeriodo + N' EDOD
          		ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
          		WHERE ED.IdExpediente=@pIdExpediente
          		AND((EDOD.IdCargoDestino = @vIdCargoJefeEsMio and EDOD.IdAreaDestino=@vIdAreaJefeEsMio)
          		OR (EDO.IdCargoOrigen=@vIdCargoJefeEsMio or EDO.IdAreaOrigen=@vIdAreaJefeEsMio)))'

                exec sp_executesql @Consulta,
                    N'@pIdExpediente int, @vIdCargoJefeEsMio int, @vIdAreaJefeEsMio int, @vSiPariticipo int output',
                    @pIdExpediente = @pIdExpediente,
                    @vIdCargoJefeEsMio = @vIdCargoJefeEsMio,
                    @vIdAreaJefeEsMio = @vIdAreaJefeEsMio,
                    @vSiPariticipo = @vSiPariticipo output

                select @cta+=1
            end

  		END ELSE BEGIN
            select @vSiPariticipo = 0, @Consulta = null

            select @cta = 0, @vPeriodo = null
            while @cta < @tot begin
                select @vPeriodo = 2022 + @cta

                select @Consulta = N'\
     			SET @vSiPariticipo += (select COUNT(ED.IdPersonaEmisor)
     			FROM Tramite.ExpedienteDocumento_historico_' + @vPeriodo + N' ED
     			INNER JOIN Tramite.ExpedienteDocumentoOrigen_historico_' + @vPeriodo + N' EDO
     			ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
     			INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_historico_' + @vPeriodo + N' EDOD
     			ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
     			WHERE ED.IdExpediente=@pIdExpediente
     			AND (EDOD.IdPersonaDestino = @vIdPersonaActual OR EDO.IdPersonaOrigen=@vIdPersonaActual))'

                exec sp_executesql @Consulta,
                    N'@pIdExpediente int, @vIdPersonaActual int, @vSiPariticipo int output',
                    @pIdExpediente = @pIdExpediente,
                    @vIdPersonaActual = @vIdPersonaActual,
                    @vSiPariticipo = @vSiPariticipo output

                select @cta+=1
            end

        END
	END


    IF @pCorrelativoVinculado>=0
	BEGIN
		SET @vCondicionVinculado=concat(' AND ED.CorrelativoVinculado =',@pCorrelativoVinculado)
	END
    SET @Orden=' ORDER BY CONVERT(DATETIME,EDO.FechaOrigen+'' ''+EDO.HoraOrigen)  DESC '
    SET @Offset= ' OFFSET ' +CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS '
    SET @Fetch= ' FETCH NEXT '+CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY '

    IF isnull(@pBusquedaGeneral,'')<>'' SET @Filtros =' AND (CSM.Descripcion LIKE ''%'+@pBusquedaGeneral +'%'')'


    select @cta = 0, @vPeriodo = null
    while @cta < @tot begin
        select @vPeriodo = 2022 + @cta

        select @Consulta = null
        select @Consulta= N'\
        insert into #tmp001_dato_expediente01 SELECT
        ED.FgEnEsperaFirmaDigital,EDO.EsVinculado,E.ExpedienteAnulado,E.IdExpediente,ED.IdExpedienteDocumento,EDOD.IdExpedienteDocumentoOrigen,EDOD.IdCatalogoSituacionMovimientoDestino,
        EDOD.IdCatalogoTipoMovimientoDestino,EDO.IdCatalogoTipodevolucion,EDOD.NumeroDiasAtencionSolicitado,EDOD.FechaDestinoRecepciona,
        EDOD.HoraDestinoRecepciona,EDO.IdEmpresaOrigen,EDO.IdAreaOrigen,EDO.IdCargoOrigen,EDOD.IdEmpresaDestino,EDOD.IdAreaDestino,EDOD.IdCargoDestino,EDOD.IdEmpresaDestinoRecepciona,EDOD.IdAreaDestinoRecepciona,
        EDOD.IdCargoDestinoRecepciona,EDOD.IdPersonaDestinoRecepciona,EDOD.IdEmpresaDestinoAtencion,EDOD.IdAreaDestinoAtencion,EDOD.IdCargoDestinoAtencion,EDOD.IdPersonaDestinoAtencion,
        EDOD.IdPersonaDestino,EDO.IdPersonaOrigen,EDO.NombreCompletoOrigen,EDOD.NumeroDiasAtencionAceptado,EDOD.Original,EDOD.Copia,EDOD.FechaDestino,EDOD.HoraDestino,EDOD.FechaDestinoEnvia,EDOD.HoraDestinoEnvia,
        EDOD.DestinatarioDestino,EDOD.ObservacionesDestinatario,MAXDES.Acciones,EDOD.IdExpedienteDocumentoOrigenDestino,ED.NumeroDocumento,ED.AsuntoDocumento,ED.RutaArchivoDocumento,EDOD.FechaArchivado,EDOD.HoraArchivado,
        EDO.Descripciondevolucion,ESEXTOR.EsExtornable,EDOD.EsInicial,EDOD.MotivoArchivado,ED.CorrelativoVinculado,ED.FgEsObligatorioFirmaDigital,ED.FlagParaDespacho,ED.IdExpedienteVirtual,EDO.FechaOrigen,EDO.HoraOrigen,ED.IdCatalogoTipoDocumento,CSM.Descripcion
        FROM Tramite.Expediente_historico_' + @vPeriodo + N' E
        INNER JOIN Tramite.ExpedienteDocumento_historico_' + @vPeriodo + N' ED ON ED.IdExpediente=E.IdExpediente
        INNER JOIN Tramite.ExpedienteDocumentoOrigen_historico_' + @vPeriodo + N' EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_historico_' + @vPeriodo + N' EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
        INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
        OUTER APPLY (
            SELECT STRING_AGG(RTRIM(CA1.Descripcion), '', '') WITHIN GROUP(ORDER BY A1.IdExpedienteDocumentoOrigenDestinoAccion) AS Acciones
            FROM Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_' + @vPeriodo + N' A1
            INNER JOIN Tramite.Catalogo CA1 ON CA1.IdCatalogo = A1.IdCatalogoTipoAccion
            WHERE A1.IdExpedienteDocumentoOrigenDestino = EDOD.IdExpedienteDocumentoOrigenDestino AND A1.EstadoAuditoria = 1
        ) MAXDES
        OUTER APPLY(
            SELECT CASE WHEN EXISTS (
                SELECT 1 FROM Tramite.ExpedienteDocumentoOrigenDestino_historico_' + @vPeriodo + N' edod3
                WHERE edod3.IdExpedienteDocumentoOrigenDestinoAnterior = EDOD.IdExpedienteDocumentoOrigenDestino
                    AND edod3.EstadoAuditoria = 1
                    AND edod3.FechaDestinoRecepciona IS NOT NULL
                    AND edod3.FechaDestinoRecepciona <> ''''
            ) THEN 0 ELSE 1 END AS EsExtornable
        ) ESEXTOR
        WHERE EDOD.EstadoAuditoria=1 AND E.IdExpediente=@pIdExpediente '
        +@vCondicionVinculado
        +@Filtros

        EXEC sp_executesql @Consulta, N'@pIdExpediente int, @vIdPersonaActual int', @pIdExpediente, @vIdPersonaActual

        select @cta+=1
    end

    select
    cast(case when t.FgEnEsperaFirmaDigital=1 then 0 else @vSiPariticipo end as int) SiPariticipo,
    t.EsVinculado,
    t.ExpedienteAnulado,
    t.IdExpediente,
    t.IdExpedienteDocumento,
    t.IdExpedienteDocumentoOrigenDestino,
    t.IdExpedienteDocumentoOrigen,
    t.IdCatalogoSituacionMovimientoDestino,
    t.Descripcion CatalogoSituacionMovimientoDestino,
    t.IdCatalogoTipoMovimientoDestino,
    CTM.Descripcion CatalogoTipoMovimientoDestino,
    isnull(t.IdCatalogoTipodevolucion,0) IdCatalogoTipodevolucion,
    t.NumeroDiasAtencionSolicitado,
    isnull(t.FechaDestinoRecepciona, '')FechaDestinoRecepciona,
    isnull(t.HoraDestinoRecepciona, '')HoraDestinoRecepciona,
    isnull(EMO.NombreEmpresa, '') NombreEmpresaOrigen,
    isnull(AO.NombreArea,'') NombreAreaOrigen,
    isnull(CO.NombreCargo,'') NombreCargoOrigen,
    isnull(Seguridad.funObtenerRutaFotoPorIdPersona(t.IdPersonaOrigen),'sinfotoH.jpg') RutaFotoPersona,
    isnull(Seguridad.funObtenerRutaFotoPorIdPersona(t.IdPersonaDestino),'sinfotoH.jpg') RutaFotoPersonaDestino,
    CASE WHEN t.IdPersonaOrigen=0 THEN t.NombreCompletoOrigen ELSE PO.NombreCompleto END NombrePersonaOrigen,
    isnull(Seguridad.funObtenerRutaFotoPorIdPersona(t.IdPersonaDestino),'sinfotoH.jpg') RutaFotoPersonaDestino,
    t.NumeroDiasAtencionAceptado,
    t.Original,
    t.Copia,
    t.FechaDestino,
    t.HoraDestino,
    isnull(t.FechaDestinoEnvia,'') FechaDestinoEnvia,
    isnull(t.HoraDestinoEnvia,'') HoraDestinoEnvia,
    COALESCE(EMD.NombreEmpresa,t.DestinatarioDestino,'') NombreEmpresaDestino,
    isnull(AD.NombreArea,'') NombreAreaDestino,
    isnull(CD.NombreCargo,'') NombreCargoDestino,
    isnull(PD.NombreCompleto,'') NombrePersonaDestino,
    isnull(EMR.NombreEmpresa, 'EXTERNO') NombreEmpresaDestinoRecepciona,
    isnull(AR.NombreArea,'') NombreAreaDestinoRecepciona,
    isnull(CR.NombreCargo,'') NombreCargoDestinoRecepciona,
    isnull(PR.NombreCompleto,'') NombrePersonaDestinoRecepciona,
    isnull(EMA.NombreEmpresa, 'EXTERNO') NombreEmpresaDestinoAtencion,
    isnull(AA.NombreArea,'') NombreAreaDestinoAtencion,
    isnull(CA.NombreCargo,'') NombreCargoDestinoAtencion,
    isnull(PA.NombreCompleto,'') NombrePersonaDestinoAtencion,
    isnull(t.ObservacionesDestinatario,'') ObservacionesDestinatario,
    isnull(Acciones, '') Acciones,
    t.IdExpedienteDocumento,
    isnull(CTD.Descripcion,'') CatalogoTipoDocumento,
    isnull(t.NumeroDocumento,'') NumeroDocumento,
    isnull(t.AsuntoDocumento,'') AsuntoDocumento,
    isnull(t.RutaArchivoDocumento,'') RutaArchivoDocumento,
    isnull(t.FechaArchivado,'') +' '+ isnull(t.HoraArchivado,'') FechaArchivado,
    isnull(t.Descripciondevolucion,'') Descripciondevolucion,
    EsExtornable,
    t.EsInicial,
    isnull(t.Descripciondevolucion,'') Descripciondevolucion,
    isnull(t.MotivoArchivado,'') MotivoArchivado,
    isnull(EE.FechaEntregaDocumento,'') FechaEntregaDocumento,
    isnull(EE.HoraEntregaDocumento,'') HoraEntregaDocumento,
    isnull(EE.RutaArchivoCargo,'') RutaArchivoCargo,
    t.CorrelativoVinculado,
    isnull(CTD.Descripcion,'') CatalogoTipoDocumento,
    CTD.IdCatalogo IdCatalogoTipoDocumento,
    t.FgEsObligatorioFirmaDigital,
    t.FgEnEsperaFirmaDigital,
    t.FlagParaDespacho,
    isnull(t.IdExpedienteVirtual,0) IdExpedienteVirtual
    from #tmp001_dato_expediente01 t
    INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=t.IdCatalogoTipoDocumento
    INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=t.IdCatalogoTipoMovimientoDestino
    LEFT JOIN General.Empresa EMO ON EMO.IdEmpresa=t.IdEmpresaOrigen
    LEFT JOIN General.Area AO ON AO.IdArea=t.IdAreaOrigen
    LEFT JOIN General.Cargo CO ON CO.IdCargo=t.IdCargoOrigen
    LEFT JOIN General.Empresa EMD ON EMD.IdEmpresa=t.IdEmpresaDestino
    LEFT JOIN General.Area AD ON AD.IdArea= t.IdAreaDestino
    LEFT JOIN General.Cargo CD ON CD.IdCargo=t.IdCargoDestino
    LEFT JOIN General.Persona PD ON PD.IdPersona=t.IdPersonaDestino
    LEFT JOIN General.Persona PO ON PO.IdPersona=t.IdPersonaOrigen
    LEFT JOIN General.Empresa EMR ON EMR.IdEmpresa=t.IdEmpresaDestinoRecepciona
    LEFT JOIN General.Area AR ON AR.IdArea= t.IdAreaDestinoRecepciona
    LEFT JOIN General.Cargo CR ON CR.IdCargo=t.IdCargoDestinoRecepciona
    LEFT JOIN General.Persona PR ON PR.IdPersona=t.IdPersonaDestinoRecepciona
    LEFT JOIN General.Empresa EMA ON EMA.IdEmpresa=t.IdEmpresaDestinoAtencion
    LEFT JOIN General.Area AA ON AA.IdArea= t.IdAreaDestinoAtencion
    LEFT JOIN General.Cargo CA ON CA.IdCargo=t.IdCargoDestinoAtencion
    LEFT JOIN General.Persona PA ON PA.IdPersona=t.IdPersonaDestinoAtencion
    LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino = t.IdExpedienteDocumentoOrigenDestino
    AND EE.EstadoAuditoria=1 AND EE.FgEntregado=0
    order by convert(datetime, t.FechaOrigen +' '+ t.HoraOrigen) desc
    OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS FETCH NEXT @pDimensionPagina ROWS ONLY

    select count(1) from #tmp001_dato_expediente01

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
    @ERROR_PROCEDURE='Tramite.paListarDetalleBusquedaExpedienteGeneral_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO


-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneralPorAnno_arq 727733,79,349,null,null,1,25,null,-1, 2025

EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 797442,79,349,null,null,1,25,null,-1, 2025
EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 506369,79,349,null,null,1,25,null,-1, 2025
EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 506369,79,349,null,null,1,25,null,-1, 2026


-- SELECT
-- @pIdExpediente= 727730,  -- 797442, --
-- @pIdArea=79,
-- @pIdUsuarioAuditoria=349,
-- @pCampoOrdenado=null,
-- @pTipoOrdenacion=null,
-- @pNumeroPagina= 1,
-- @pDimensionPagina= 25,
-- @pBusquedaGeneral= null,
-- @pCorrelativoVinculado= -1,
-- @pIdPeriodo= 2025





-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral 727733,79,349,null,null,1,25,null,-1
-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 727733,79,349,null,null,1,25,null,-1, 2025


-- exec Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 727730,79,349,null,null,1,25,null,-1, 2025
-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 727730,79,349,null,null,1,25,null,-1, 2025
-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 797442,79,349,null,null,1,25,null,-1, 2025
-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 506369,79,349,null,null,1,25,null,-1, 2025



-- SELECT
-- @pIdExpediente= 727730,
-- @pIdArea=79,
-- @pIdUsuarioAuditoria=349,
-- @pCampoOrdenado=null,
-- @pTipoOrdenacion=null,
-- @pNumeroPagina= 1,
-- @pDimensionPagina= 25,
-- @pBusquedaGeneral= null,
-- @pCorrelativoVinculado= -1,
-- @pIdPeriodo= 2025
--
