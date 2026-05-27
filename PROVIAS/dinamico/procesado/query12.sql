-- alter PROCEDURE Tramite.paListarDetalleBusquedaExpedienteGeneralPorAnno_arq
declare
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
-- AS
-- BEGIN
-- BEGIN TRY
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
SET LANGUAGE SPANISH


SELECT
@pIdExpediente= 727733,  -- 797442, --
@pIdArea=79,
@pIdUsuarioAuditoria=349,
@pCampoOrdenado=null,
@pTipoOrdenacion=null,
@pNumeroPagina= 1,
@pDimensionPagina= 25,
@pBusquedaGeneral= null,
@pCorrelativoVinculado= -1,
@pIdPeriodo= 2025

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
    IdExpedienteDocumentoOrigenDestino int,
    NumeroDocumento varchar(200) collate database_default,
    AsuntoDocumento varchar(8000) collate database_default,
    RutaArchivoDocumento varchar(150) collate database_default,
    FechaArchivado varchar(10) collate database_default,
    HoraArchivado varchar(5) collate database_default,
    Descripciondevolucion varchar(4000) collate database_default,
    EsInicial int,
    MotivoArchivado varchar(8000) collate database_default,
    CorrelativoVinculado int,
    FgEsObligatorioFirmaDigital bit,
    FlagParaDespacho bit,
    IdExpedienteVirtual int,
    FechaOrigen varchar(10) collate database_default,
    HoraOrigen varchar(5) collate database_default,
    IdCatalogoTipoDocumento int
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

	declare @vAnno int = year(getdate()), @vItera int = 0, @vNuevoPeriodo int
	declare @vTotalItera int = @vAnno - @pIdPeriodo + 1
	declare @vcExpediente varchar(100) = 'select*from Tramite.Expediente'
	declare @vcExpedienteDocumento varchar(100) = 'select*from Tramite.ExpedienteDocumento'
	declare @vcExpedienteDocumentoOrigen varchar(100) = 'select*from Tramite.ExpedienteDocumentoOrigen'
	declare @vcExpedienteDocumentoOrigenDestino varchar(100) = 'select*from Tramite.ExpedienteDocumentoOrigenDestino'
	declare @vcExpedienteRpta varchar(2000) = ''
	declare @vcExpedienteDocumentoRpta varchar(2000) = ''
	declare @vcExpedienteDocumentoOrigenRpta varchar(2000) = ''
	declare @vcExpedienteDocumentoOrigenDestinoRpta varchar(2000) = ''
	while(@vItera < @vTotalItera)begin
	    select @vNuevoPeriodo = @pIdPeriodo + @vItera
		if(@vNuevoPeriodo = @vAnno) begin
		     select @vcExpedienteRpta+=@vcExpediente
            select @vcExpedienteDocumentoRpta+=@vcExpedienteDocumento
            select @vcExpedienteDocumentoOrigenRpta+=@vcExpedienteDocumentoOrigen
            select @vcExpedienteDocumentoOrigenDestinoRpta+=@vcExpedienteDocumentoOrigenDestino
		end else begin
			select @vcExpedienteRpta+=concat(@vcExpediente,'_historico_',@vNuevoPeriodo)
            select @vcExpedienteDocumentoRpta+=concat(@vcExpedienteDocumento,'_historico_',@vNuevoPeriodo)
            select @vcExpedienteDocumentoOrigenRpta+=concat(@vcExpedienteDocumentoOrigen,'_historico_',@vNuevoPeriodo)
            select @vcExpedienteDocumentoOrigenDestinoRpta+=concat(@vcExpedienteDocumentoOrigenDestino,'_historico_',@vNuevoPeriodo)
		end
		if(@vItera < @vTotalItera-1)begin
		    select @vcExpedienteRpta+=' union all '
            select @vcExpedienteDocumentoRpta+=' union all '
            select @vcExpedienteDocumentoOrigenRpta+=' union all '
            select @vcExpedienteDocumentoOrigenDestinoRpta+=' union all '
		end
	    select @vItera+=1
	end


	IF @vIdTipoFormulario>0
	BEGIN
		SET @vSiPariticipo=1
	END ELSE BEGIN
	    IF(SELECT COUNT(*) FROM RecursoHumano.visPersonaJefe WHERE IdPersona = @vIdPersonaActual AND IdArea=@pIdArea)>0
  		BEGIN
      		SELECT @vIdCargoJefeEsMio=IdCargo, @vIdAreaJefeEsMio=IdArea,@vIdEmpresaJefeEsMio=IdEmpresa
      		FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea AND IdPersona = @vIdPersonaActual

            select @Consulta = N'
       	    SET @vSiPariticipo=(select COUNT(ED.IdPersonaEmisor)
      		FROM (' + @vcExpedienteDocumentoRpta + N')ED
      		INNER JOIN (' + @vcExpedienteDocumentoOrigenRpta + N')EDO
      		ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
      		INNER JOIN (' + @vcExpedienteDocumentoOrigenDestinoRpta + N')EDOD
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
  		END ELSE BEGIN
            select @Consulta = N'
 			SET @vSiPariticipo=(select COUNT(ED.IdPersonaEmisor)
 			FROM (' + @vcExpedienteDocumentoRpta + N')ED
 			INNER JOIN (' + @vcExpedienteDocumentoOrigenRpta + N')EDO
 			ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
 			INNER JOIN (' + @vcExpedienteDocumentoOrigenDestinoRpta + N')EDOD
 			ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
 			WHERE ED.IdExpediente=@pIdExpediente
 			AND (EDOD.IdPersonaDestino = @vIdPersonaActual OR EDO.IdPersonaOrigen=@vIdPersonaActual))'

            exec sp_executesql @Consulta,
                N'@pIdExpediente int, @vIdPersonaActual int, @vSiPariticipo int output',
                @pIdExpediente = @pIdExpediente,
                @vIdPersonaActual = @vIdPersonaActual,
                @vSiPariticipo = @vSiPariticipo output
        END
	END

    IF @pCorrelativoVinculado>=0
	BEGIN
		SET @vCondicionVinculado=' AND ED.CorrelativoVinculado ='+CONVERT(Nvarchar,@pCorrelativoVinculado)
	END
    SET @Orden=' ORDER BY CONVERT(DATETIME,EDO.FechaOrigen+'' ''+EDO.HoraOrigen)  DESC '
    SET @Offset= ' OFFSET ' +CONVERT(VARCHAR(10),(@pNumeroPagina-1)*@pDimensionPagina) + ' ROWS '
    SET @Fetch= ' FETCH NEXT '+CONVERT(VARCHAR(10),@pDimensionPagina) +' ROWS ONLY '

    IF isnull(@pBusquedaGeneral,'')<>'' SET @Filtros =' AND (CSM.Descripcion LIKE ''%'+@pBusquedaGeneral +'%'')'

    select @Consulta = null
    select @Consulta= N'
    insert into #tmp001_dato_expediente01 SELECT
    ED.FgEnEsperaFirmaDigital,EDO.EsVinculado,E.ExpedienteAnulado,E.IdExpediente,ED.IdExpedienteDocumento,EDOD.IdExpedienteDocumentoOrigen,EDOD.IdCatalogoSituacionMovimientoDestino,
    EDOD.IdCatalogoTipoMovimientoDestino,EDO.IdCatalogoTipodevolucion,EDOD.NumeroDiasAtencionSolicitado,EDOD.FechaDestinoRecepciona,
    EDOD.HoraDestinoRecepciona,EDO.IdEmpresaOrigen,EDO.IdAreaOrigen,EDO.IdCargoOrigen,EDOD.IdEmpresaDestino,EDOD.IdAreaDestino,EDOD.IdCargoDestino,EDOD.IdEmpresaDestinoRecepciona,EDOD.IdAreaDestinoRecepciona,
    EDOD.IdCargoDestinoRecepciona,EDOD.IdPersonaDestinoRecepciona,EDOD.IdEmpresaDestinoAtencion,EDOD.IdAreaDestinoAtencion,EDOD.IdCargoDestinoAtencion,EDOD.IdPersonaDestinoAtencion,
    EDOD.IdPersonaDestino,EDO.IdPersonaOrigen,EDO.NombreCompletoOrigen,EDOD.NumeroDiasAtencionAceptado,EDOD.Original,EDOD.Copia,EDOD.FechaDestino,EDOD.HoraDestino,EDOD.FechaDestinoEnvia,EDOD.HoraDestinoEnvia,
    EDOD.DestinatarioDestino,EDOD.ObservacionesDestinatario,EDOD.IdExpedienteDocumentoOrigenDestino,ED.NumeroDocumento,ED.AsuntoDocumento,ED.RutaArchivoDocumento,EDOD.FechaArchivado,EDOD.HoraArchivado,
    EDO.Descripciondevolucion,EDOD.EsInicial,EDOD.MotivoArchivado,ED.CorrelativoVinculado,ED.FgEsObligatorioFirmaDigital,ED.FlagParaDespacho,ED.IdExpedienteVirtual,EDO.FechaOrigen,EDO.HoraOrigen,ED.IdCatalogoTipoDocumento
    FROM (' + @vcExpedienteRpta + N')E
    INNER JOIN (' + @vcExpedienteDocumentoRpta + N')ED ON ED.IdExpediente=E.IdExpediente
    INNER JOIN (' + @vcExpedienteDocumentoOrigenRpta + N')EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
    INNER JOIN (' + @vcExpedienteDocumentoOrigenDestinoRpta + N')EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen  AND EDO.EstadoAuditoria=1
    WHERE EDOD.EstadoAuditoria=1 AND E.IdExpediente=@pIdExpediente'
    +@vCondicionVinculado

    EXECUTE sp_executesql @Consulta,
    N'@pIdExpediente int, @vIdPersonaActual int',
    @pIdExpediente = @pIdExpediente,
    @vIdPersonaActual = @vIdPersonaActual


-- insert into #tmp001_expediente_listar

    select
    case when t.FgEnEsperaFirmaDigital=1 then 0 else @vSiPariticipo end SiPariticipo,
    t.EsVinculado,
    t.ExpedienteAnulado,
    t.IdExpediente,
    t.IdExpedienteDocumento,
    t.IdExpedienteDocumentoOrigenDestino,
    t.IdExpedienteDocumentoOrigen,
    t.IdCatalogoSituacionMovimientoDestino,
    CSM.Descripcion,
    t.IdCatalogoTipoMovimientoDestino,
    CTM.Descripcion,
    t.IdCatalogoTipodevolucion,
    t.NumeroDiasAtencionSolicitado,
    t.FechaDestinoRecepciona,
    t.HoraDestinoRecepciona,
    EMO.NombreEmpresa,
    AO.NombreArea,
    CO.NombreCargo,
    Seguridad.funObtenerRutaFotoPorIdPersona(t.IdPersonaOrigen),
    Seguridad.funObtenerRutaFotoPorIdPersona(t.IdPersonaDestino),
    CASE WHEN t.IdPersonaOrigen=0 THEN t.NombreCompletoOrigen ELSE PO.NombreCompleto END,
    null,
    t.NumeroDiasAtencionAceptado,
    t.Original,
    t.Copia,
    t.FechaDestino,
    t.HoraDestino,
    t.FechaDestinoEnvia,
    t.HoraDestinoEnvia,
    COALESCE(EMD.NombreEmpresa,t.DestinatarioDestino,''),
    AD.NombreArea,
    CD.NombreCargo,
    PD.NombreCompleto,
    EMR.NombreEmpresa,
    AR.NombreArea,
    CR.NombreCargo,
    PR.NombreCompleto,
    EMA.NombreEmpresa,
    AA.NombreArea,
    CA.NombreCargo,
    PA.NombreCompleto,
    t.ObservacionesDestinatario,
    Tramite.funMostrarAccionesPorDestino(t.IdExpedienteDocumentoOrigenDestino),
    null,
    CTD.Descripcion,
    t.NumeroDocumento,
    t.AsuntoDocumento,
    t.RutaArchivoDocumento,
    t.FechaArchivado,
    t.HoraArchivado,
    t.Descripciondevolucion,
    Tramite.funEsExtornable(t.IdExpedienteDocumentoOrigen,t.IdExpedienteDocumentoOrigenDestino),
    t.EsInicial,
    null,
    t.MotivoArchivado,
    EE.FechaEntregaDocumento,
    EE.HoraEntregaDocumento,
    EE.RutaArchivoCargo,
    t.CorrelativoVinculado,
    null,
    CTD.IdCatalogo,
    t.FgEsObligatorioFirmaDigital,
    t.FgEnEsperaFirmaDigital,
    t.FlagParaDespacho,
    t.IdExpedienteVirtual,
    concat(t.FechaOrigen,t.HoraOrigen)
    from #tmp001_dato_expediente01 t
    INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=t.IdCatalogoTipoDocumento
    INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=t.IdCatalogoSituacionMovimientoDestino
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
-- +@Filtros


SELECT
    SiPariticipo,
    EsVinculado,
    ExpedienteAnulado,
    IdExpediente,
    IdExpedienteDocumento,
    IdExpedienteDocumentoOrigenDestino,
    IdExpedienteDocumentoOrigen,
    IdCatalogoSituacionMovimientoDestino,
    CatalogoSituacionMovimientoDestino,
    IdCatalogoTipoMovimientoDestino,
    CatalogoTipoMovimientoDestino,
    isnull(IdCatalogoTipoDevolucion, 0) IdCatalogoTipoDevolucion,
    NumeroDiasAtencionSolicitado,
    isnull(FechaDestinoRecepciona, '') FechaDestinoRecepciona,
    isnull(HoraDestinoRecepciona,'') HoraDestinoRecepciona,
    isnull(NombreEmpresaOrigen,'') NombreEmpresaOrigen,
    isnull(NombreAreaOrigen,'') NombreAreaOrigen,
    isnull(NombreCargoOrigen,'') NombreCargoOrigen,
    isnull(RutaFotoPersona,'sinfotoH.jpg') RutaFotoPersona,
    isnull(RutaFotoPersonaDestino,'sinfotoH.jpg') RutaFotoPersonaDestino,
    NombrePersonaOrigen,
    isnull(RutaFotoPersonaDestino,'sinfotoH.jpg') RutaFotoPersonaDestino,
    NumeroDiasAtencionAceptado,
    Original,
    Copia,
    FechaDestino,
    HoraDestino,
    isnull(FechaDestinoEnvia,'') FechaDestinoEnvia,
    isnull(HoraDestinoEnvia,'') HoraDestinoEnvia,
    NombreEmpresaDestino,
    isnull(NombreAreaDestino,'') NombreAreaDestino,
    isnull(NombreCargoDestino,'') NombreCargoDestino,
    isnull(NombrePersonaDestino,'') NombrePersonaDestino,
    isnull(NombreEmpresaDestinoRecepciona, 'EXTERNO') NombreEmpresaDestinoRecepciona,
    isnull(NombreAreaDestinoRecepciona,'') NombreAreaDestinoRecepciona,
    isnull(NombreCargoDestinoRecepciona,'') NombreCargoDestinoRecepciona,
    isnull(NombrePersonaDestinoRecepciona,'') NombrePersonaDestinoRecepciona,
    isnull(NombreEmpresaDestinoAtencion, 'EXTERNO') NombreEmpresaDestinoAtencion,
    isnull(NombreAreaDestinoAtencion,'') NombreAreaDestinoAtencion,
    isnull(NombreCargoDestinoAtencion,'') NombreCargoDestinoAtencion,
    isnull(NombrePersonaDestinoAtencion,'') NombrePersonaDestinoAtencion,
    isnull(ObservacionesDestinatario,'') ObservacionesDestinatario,
    Acciones,
    IdExpedienteDocumento,
    CatalogoTipoDocumento,
    isnull(NumeroDocumento,'') NumeroDocumento,
    isnull(AsuntoDocumento,'') AsuntoDocumento,
    isnull(RutaArchivoDocumento,'') RutaArchivoDocumento,
    isnull(FechaArchivado,'') +' '+ isnull(HoraArchivado,'') FechaArchivado,
    isnull(DescripcionDevolucion,'') DescripcionDevolucion,
    EsExtornable,
    EsInicial,
    isnull(DescripcionDevolucion,'') DescripcionDevolucion,
    isnull(MotivoArchivado, '') MotivoArchivado,
    isnull(FechaEntregaDocumento, '') FechaEntregaDocumento,
    isnull(HoraEntregaDocumento, '') HoraEntregaDocumento,
    isnull(RutaArchivoCargo, '') RutaArchivoCargo,
    CorrelativoVinculado,
    CatalogoTipoDocumento,
    IdCatalogoTipoDocumento,
    FgEsObligatorioFirmaDigital,
    FgEnEsperaFirmaDigital,
    FlagParaDespacho,
    isnull(IdExpedienteVirtual, 0) IdExpedienteVirtual
FROM #tmp001_expediente_listar
order by convert(datetime, substring(fechaOrden,1,10) +' '+ stuff(fechaOrden,1,10,'')) desc
OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS FETCH NEXT @pDimensionPagina ROWS ONLY

select count(1) from #tmp001_expediente_listar














-- END TRY
-- BEGIN CATCH
--     DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
--     SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
--     @ERROR_PROCEDURE='Tramite.paListarDetalleBusquedaExpedienteGeneralPorAnno_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
--     EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
-- END CATCH
-- END
-- GO


-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneralPorAnno_arq 727733,79,349,null,null,1,25,null,-1, 2025

-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 797442,79,349,null,null,1,25,null,-1, 2025
-- EXECUTE Tramite.paListarDetalleBusquedaExpedienteGeneral_arq 506369,79,349,null,null,1,25,null,-1, 2025



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
