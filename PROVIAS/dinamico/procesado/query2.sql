create or alter PROCEDURE Tramite.paListarDocumentoPendienteEspecialistaV1_arq
    @pIdExpediente int,
    @pIdEmpresa int,
    @pIdArea int,
    @pIdCargo int,
    @pIdPersona int,
    @pIdUsuarioAuditoria int,
    @pCampoOrdenado varchar(50),
    @pTipoOrdenacion varchar(4),
    @pNumeroPagina INT,
    @pDimensionPagina  INT,
    @pBusquedaGeneral varchar(100),
    @pVerSoloMio int,
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

create table #tmp001_expedientePrueba(
    SiPariticipo int,
    Logueo nvarchar(4000) collate database_default,
    PaseTieneAdjunto int,
    DocumentoTieneAdjunto int,
    NombreExpediente varchar(62) collate database_default,
    CorrelativoVinculado int,
    EsVinculado bit,
    ExpedienteAnulado bit,
    IdExpediente int,
    IdExpedienteDocumento int,
    IdExpedienteDocumentoOrigenDestino int,
    IdExpedienteDocumentoOrigen int,
    IdCatalogoSituacionMovimientoDestino int,
    CatalogoSituacionMovimientoDestino varchar(400) collate database_default,
    IdCatalogoTipoMovimientoDestino int,
    CatalogoTipoMovimientoDestino varchar(400) collate database_default,
    IdCatalogoTipoDevolucion int,
    NumeroDiasAtencionSolicitado int,
    FechaDestinoRecepciona varchar(10) collate database_default,
    HoraDestinoRecepciona varchar(5) collate database_default,
    NombreEmpresaOrigen varchar(100) collate database_default,
    NombreAreaOrigen varchar(500) collate database_default,
    NombreCargoOrigen varchar(200) collate database_default,
    NombrePersonaOrigen varchar(400) collate database_default,
    RutaFotoPersona varchar(max) collate database_default,
    RutaFotoPersonaDestino varchar(max) collate database_default,
    NumeroDiasAtencionAceptado int,
    Original bit,
    IdCatalogoTipoTramite int,
    Copia bit,
    FechaDestino varchar(10) collate database_default,
    HoraDestino varchar(5) collate database_default,
    FechaOrigen varchar(10) collate database_default,
    HoraOrigen varchar(5) collate database_default,
    FechaDestinoEnvia varchar(10) collate database_default,
    HoraDestinoEnvia varchar(5) collate database_default,
    NombreEmpresaDestino varchar(800) collate database_default,
    NombreAreaDestino varchar(500) collate database_default,
    NombreCargoDestino varchar(200) collate database_default,
    RutaFotoPersonaDestino2 varchar(max) collate database_default,
    NombrePersonaDestino varchar(400) collate database_default,
    NombreEmpresaDestinoRecepciona varchar(100) collate database_default,
    NombreAreaDestinoRecepciona varchar(500) collate database_default,
    NombreCargoDestinoRecepciona varchar(200) collate database_default,
    NombrePersonaDestinoRecepciona varchar(400) collate database_default,
    NombreEmpresaDestinoAtencion varchar(100) collate database_default,
    NombreAreaDestinoAtencion varchar(500) collate database_default,
    NombreCargoDestinoAtencion varchar(200) collate database_default,
    NombrePersonaDestinoAtencion varchar(400) collate database_default,
    ObservacionesDestinatario varchar(4000) collate database_default,
    Acciones varchar(max) collate database_default,
    IdExpedienteDocumento2 int,
    EsPropio int,
    EsMiDocumento int,
    EsOrigen int,
    IdExpedienteDocumento3 int,
    CatalogoTipoDocumento varchar(400) collate database_default,
    NumeroDocumento varchar(601) collate database_default,
    AsuntoDocumento varchar(8000) collate database_default,
    RutaArchivoDocumento varchar(150) collate database_default,
    FechaCreacionAuditoria nvarchar(4000) collate database_default,
    FechaArchivado varchar(10) collate database_default,
    EsExtornable int,
    EsInicial int,
    DescripcionDevolucion varchar(4000) collate database_default,
    MotivoArchivado varchar(8000) collate database_default,
    FechaEntregaDocumento varchar(10) collate database_default,
    HoraEntregaDocumento varchar(5) collate database_default,
    RutaArchivoCargo varchar(100) collate database_default,
    FgEsObligatorioFirmaDigital bit,
    FgEnEsperaFirmaDigital bit,
    FlagParaDespacho bit,
    PeriodoCreadoDocumento varchar(30) collate database_default
);

		--VERIFICANDO SI PARTICIPO EN EL EXPEDIENTE, DE LO CONTRARIO NO PODRÉ VER EL DOCUMENTO
        DECLARE @vIdPersonaActual int = 0, @vSiPariticipo int = 0, @sql NVARCHAR(MAX)
        DECLARE @vIdPeriodo varchar(4) = convert(varchar, @pIdPeriodo)
        SELECT @vIdPersonaActual=IdPersona from Seguridad.Usuario
        where IdUsuario=@pIdUsuarioAuditoria AND EstadoAuditoria=1 AND Bloqueado=0

        select @vSiPariticipo = 1
        where exists(
            select 1
            from Tramite.PermisoVisualizacionDocumentos
			where   IdTipoFormulario = 2
			    and EstadoAuditoria  = 1
				and convert(date, getdate()) between convert(date,FechaInicioPersmiso) and convert(date,FechaFinPersmiso)
				and IdUsuario = @pIdUsuarioAuditoria
        )

		if @vSiPariticipo = 0 BEGIN
		    select @sql = N'
			select @vSiPariticipo= COUNT(ED.IdPersonaEmisor)
			FROM Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
			INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
			    ON EDO.IdExpedienteDocumento = ED.IdExpedienteDocumento
				AND ED.EstadoAuditoria = 1
			INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
			    ON EDOD.IdExpedienteDocumentoOrigen = EDO.IdExpedienteDocumentoOrigen
				AND EDO.EstadoAuditoria = 1
			WHERE   ED.IdExpediente = @pIdExpediente
			    AND ( EDOD.IdPersonaDestino = @vIdPersonaActual OR EDO.IdPersonaOrigen=@vIdPersonaActual)'

			EXEC sp_executesql @sql,
                N'@vSiPariticipo int output, @pIdExpediente INT, @vIdPersonaActual INT',
                @pIdExpediente = @pIdExpediente,
                @vIdPersonaActual = @vIdPersonaActual,
                @vSiPariticipo = @vSiPariticipo output

		END

	 --OBTENER EL JEFE DE AREA PARA OBTENER VALIDAR SI ES JEFE
		DECLARE @vIdCargoJefe int=0
		DECLARE @vIdAreaJefe int=0
		DECLARE @vIdEmpresaJefe int=0
		DECLARE @vEsJefe int=0
		SELECT @vIdCargoJefe=IdCargo, @vIdAreaJefe=IdArea,@vIdEmpresaJefe=IdEmpresa FROM RecursoHumano.visPersonaJefe where IdArea=@pIdArea
		IF @vIdCargoJefe=@pIdCargo AND @vIdAreaJefe=@pIdArea AND @vIdEmpresaJefe=@pIdEmpresa
		BEGIN
			SET @vEsJefe=1
		END


		 IF @pVerSoloMio=1
		 BEGIN
			select @sql = N'
		    insert into #tmp001_expedientePrueba SELECT case when ED.FgEnEsperaFirmaDigital=1 and Ver.doc=0 then 0 else @vSiPariticipo end SiPariticipo,
			Seguridad.funObtenerUsuario(edo.IdUsuarioCreacionAuditoria)Logueo,PTAD.PaseTieneAdjunto,DTAD.DocumentoTieneAdjunto,
			CONCAT(SD.AbreviaturaSerieDocumentalExpediente, RIGHT(1000000+E.NumeroExpediente,6), ''-'', E.IdPeriodo,
			CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN '''' ELSE '' V-''+CONVERT(VARCHAR,ED.CorrelativoVinculado) END) NombreExpediente,
			ED.CorrelativoVinculado, EDO.EsVinculado,E.ExpedienteAnulado,E.IdExpediente,ED.IdExpedienteDocumento, EDOD.IdExpedienteDocumentoOrigenDestino,
            EDOD.IdExpedienteDocumentoOrigen,
            CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino
                ELSE CASE WHEN EE.IdCatalogoSituacionEnvio = 14 THEN EDOD.IdCatalogoSituacionMovimientoDestino
			    ELSE EE.IdCatalogoSituacionEnvio END END IdCatalogoSituacionMovimientoDestino,
            CASE WHEN EE.IdEnvio IS NULL THEN CSM.Descripcion ELSE CASE WHEN EE.IdCatalogoSituacionEnvio = 14 THEN CSM.Descripcion
                ELSE CSMEE.Descripcion END END CatalogoSituacionMovimientoDestino,
            EDOD.IdCatalogoTipoMovimientoDestino,
            CTM.Descripcion CatalogoTipoMovimientoDestino, COALESCE(EDO.IdCatalogoTipodevolucion,0) IdCatalogoTipoDevolucion,
            EDOD.NumeroDiasAtencionSolicitado, COALESCE(EDOD.FechaDestinoRecepciona,'''')FechaDestinoRecepciona,
            COALESCE(EDOD.HoraDestinoRecepciona,'''')HoraDestinoRecepciona, COALESCE(EMO.NombreEmpresa,'''') NombreEmpresaOrigen,
			COALESCE(AO.NombreArea,'''') NombreAreaOrigen,
            CASE WHEN CTEO.IdCatalogo=9 THEN ''(LOCADOR)'' ELSE COALESCE(CO.NombreCargo,'''') END NombreCargoOrigen,
			CASE WHEN EDO.IdPersonaOrigen=0 THEN coalesce(EDO.NombreCompletoOrigen,'''') ELSE
			CASE WHEN CTM.IdCatalogo=71 THEN coalesce(EDO.NombreCompletoOrigen,'''')  ELSE coalesce(PO.NombreCompleto,'''') END END  NombrePersonaOrigen,
			COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDO.IdPersonaOrigen),''sinfotoH.jpg'') RutaFotoPersona,
			COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),''sinfotoH.jpg'') RutaFotoPersonaDestino,
			EDOD.NumeroDiasAtencionAceptado, EDOD.Original,
			CASE WHEN E.IdCatalogoTipoTramite IN (211,477,478,129,391) THEN 211 ELSE E.IdCatalogoTipoTramite  END IdCatalogoTipoTramite,
            EDOD.Copia, EDOD.FechaDestino, EDOD.HoraDestino, EDO.FechaOrigen, EDO.HoraOrigen,
            COALESCE(EDOD.FechaDestinoEnvia,'''') FechaDestinoEnvia, COALESCE(EDOD.HoraDestinoEnvia,'''') HoraDestinoEnvia,
			COALESCE(EMD.NombreEmpresa,COALESCE(EDOD.DestinatarioDestino,'''')) NombreEmpresaDestino, COALESCE(AD.NombreArea,'''') NombreAreaDestino,
			CASE WHEN CTED.IdCatalogo=9 THEN ''(LOCADOR)'' ELSE COALESCE(CD.NombreCargo,'''') END NombreCargoDestino,
			COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),''sinfotoH.jpg'') RutaFotoPersonaDestino,
            COALESCE(PD.NombreCompleto,'''') NombrePersonaDestino,
            COALESCE(EMR.NombreEmpresa,''EXTERNO'') NombreEmpresaDestinoRecepciona,
            COALESCE(AR.NombreArea,'''') NombreAreaDestinoRecepciona,
            COALESCE(CR.NombreCargo,'''') NombreCargoDestinoRecepciona,
            COALESCE(PR.NombreCompleto,'''') NombrePersonaDestinoRecepciona,
            COALESCE(EMA.NombreEmpresa,''EXTERNO'') NombreEmpresaDestinoAtencion,
            COALESCE(AA.NombreArea,'''') NombreAreaDestinoAtencion,
            COALESCE(CA.NombreCargo,'''') NombreCargoDestinoAtencion,
            COALESCE(PA.NombreCompleto,'''') NombrePersonaDestinoAtencion,
            COALESCE(EDOD.ObservacionesDestinatario,'''') ObservacionesDestinatario,MAXDES.Acciones,ED.IdExpedienteDocumento,
            CASE WHEN @vEsJefe=1 THEN 0 ELSE ESPRES.EsPropio END EsPropio,
			CASE WHEN @vEsJefe=1 THEN 0 ELSE
			CASE WHEN ED.IdCargoEmisor=@pIdCargo and ED.IdAreaEmisor=@pIdArea and ED.IdEmpresaEmisor=@pIdEmpresa and ED.IdPersonaEmisor=@pIdPersona
			    THEN 1 ELSE 0 END END EsMiDocumento,
			CASE WHEN @vEsJefe=1 THEN 0 ELSE
			CASE WHEN EDO.IdCargoOrigen=@pIdCargo and EDO.IdAreaOrigen=@pIdArea and EDO.IdEmpresaOrigen=@pIdEmpresa and EDO.IdPersonaOrigen=@pIdPersona
			    THEN 1 ELSE 0 END END EsOrigen,
            ED.IdExpedienteDocumento, CTD.Descripcion CatalogoTipoDocumento,
            CASE WHEN ED.Correlativo=0 THEN CONCAT( CTD.Descripcion,'' '', COALESCE(ED.NumeroDocumento,''''))
                ELSE COALESCE(ED.NumeroDocumento,'''') END NumeroDocumento,
            COALESCE(ED.AsuntoDocumento,'''') AsuntoDocumento,
            COALESCE(ED.RutaArchivoDocumento,'''') RutaArchivoDocumento,
			isnull(FORMAT(ED.FechaCreacionAuditoria, ''dd/MM/yyyy HH:mm''),'''') FechaCreacionAuditoria,
            COALESCE(EDOD.FechaArchivado,'''')FechaArchivado,ESEXTOR.EsExtornable,EDOD.EsInicial,
			COALESCE(EDO.Descripciondevolucion,'''') DescripcionDevolucion,
			COALESCE(EDOD.MotivoArchivado,'''')MotivoArchivado,
			COALESCE(EE.FechaEntregaDocumento,'''')FechaEntregaDocumento,
			COALESCE(EE.HoraEntregaDocumento,'''')HoraEntregaDocumento,
			COALESCE(EE.RutaArchivoCargo,'''')RutaArchivoCargo,
			ED.FgEsObligatorioFirmaDigital, ED.FgEnEsperaFirmaDigital,ED.FlagParaDespacho,
			COALESCE(CASE WHEN YEAR(DATEADD(MONTH,-1,EE.FechaCreacionAuditoria))=YEAR(GETDATE()) THEN ''''
			    ELSE CONVERT(VARCHAR, YEAR(DATEADD(MONTH,-1,EE.FechaCreacionAuditoria))) END,'''') PeriodoCreadoDocumento
        FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
        INNER JOIN Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
            ON ED.IdExpediente=E.IdExpediente
        INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
            ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
            ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
        INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
        INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
        INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
		INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
		outer apply(
			select isnull(max(1),0) doc
			from Tramite.ExpedienteDocumentoFirmante_Historico_' + @vIdPeriodo + N' EDF
			where EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.IdPersona=@vIdPersonaActual and EDF.EstadoAuditoria=1
		) Ver
        LEFT JOIN General.Empresa EMO ON EMO.IdEmpresa=EDO.IdEmpresaOrigen
        LEFT JOIN General.Empresa EMD ON EMD.IdEmpresa=EDOD.IdEmpresaDestino
        LEFT JOIN General.Empresa EMR ON EMR.IdEmpresa=EDOD.IdEmpresaDestinoRecepciona
        LEFT JOIN General.Empresa EMA ON EMA.IdEmpresa=EDOD.IdEmpresaDestinoAtencion
        LEFT JOIN General.Area AO ON AO.IdArea= EDO.IdAreaOrigen
        LEFT JOIN General.Area AD ON AD.IdArea= EDOD.IdAreaDestino
        LEFT JOIN General.Area AR ON AR.IdArea= EDOD.IdAreaDestinoRecepciona
        LEFT JOIN General.Area AA ON AA.IdArea= EDOD.IdAreaDestinoAtencion
        LEFT JOIN General.Cargo CO ON CO.IdCargo=EDO.IdCargoOrigen
        LEFT JOIN General.Cargo CD ON CD.IdCargo=EDOD.IdCargoDestino
        LEFT JOIN General.Cargo CR ON CR.IdCargo=EDOD.IdCargoDestinoRecepciona
        LEFT JOIN General.Cargo CA ON CA.IdCargo=EDOD.IdCargoDestinoAtencion
        LEFT JOIN RecursoHumano.Empleado EMPD ON EMPD.IdPersona=EDOD.IdPersonaDestino AND EMPD.EstadoAuditoria=1
        LEFT JOIN RecursoHumano.Empleado EMPO ON EMPO.IdPersona=EDO.IdPersonaOrigen AND EMPO.EstadoAuditoria=1
		LEFT JOIN General.Persona PD ON PD.IdPersona=EMPD.IdPersona AND PD.EstadoAuditoria=1
		LEFT JOIN General.Persona PO ON PO.IdPersona=EMPO.IdPersona AND PO.EstadoAuditoria=1
		LEFT JOIN General.Persona PR ON PR.IdPersona=EDOD.IdPersonaDestinoRecepciona
        LEFT JOIN General.Persona PA ON PA.IdPersona=EDOD.IdPersonaDestinoAtencion
		LEFT JOIN RecursoHumano.Catalogo CTED ON CTED.IdCatalogo=EMPD.IdCatalogoTipoEmpleado
		LEFT JOIN RecursoHumano.Catalogo CTEO ON CTEO.IdCatalogo=EMPO.IdCatalogoTipoEmpleado
		LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino = EDOD.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria = 1 AND FgEntregado = 0
		LEFT JOIN Courrier.Catalogo CSMEE ON CSMEE.IdCatalogo=EE.IdCatalogoSituacionEnvio
		OUTER APPLY(
    		SELECT COUNT(1) PaseTieneAdjunto
    		FROM Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_' + @vIdPeriodo + N' edoa1
    		WHERE edoa1.EstadoAuditoria=1 and edoa1.IdExpedienteDocumentoOrigenEDO=EDO.IdExpedienteDocumentoOrigen
		)PTAD
		OUTER APPLY(
            SELECT COUNT(1) DocumentoTieneAdjunto
    		FROM Tramite.ExpedienteDocumentoAdjunto_Historico_' + @vIdPeriodo + N' eda1
    		WHERE eda1.EstadoAuditoria=1 and eda1.IdExpedienteDocumento=ED.IdExpedienteDocumento
		)DTAD
		OUTER APPLY (
            SELECT STRING_AGG(RTRIM(CA1.Descripcion), '', '') WITHIN GROUP(ORDER BY A1.IdExpedienteDocumentoOrigenDestinoAccion) AS Acciones
            FROM Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_' + @vIdPeriodo + N' A1
            INNER JOIN Tramite.Catalogo CA1 ON CA1.IdCatalogo = A1.IdCatalogoTipoAccion
            WHERE A1.IdExpedienteDocumentoOrigenDestino = EDOD.IdExpedienteDocumentoOrigenDestino AND A1.EstadoAuditoria = 1
        ) MAXDES
        OUTER APPLY (
            SELECT CASE WHEN EXISTS (
                SELECT 1 FROM Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD2
                WHERE EDOD2.IdPersonaDestino = @pIdPersona AND
                      EDOD2.IdCargoDestino = @pIdCargo AND
                      EDOD2.IdAreaDestino = @pIdArea AND
                      EDOD2.IdEmpresaDestino = @pIdEmpresa AND
                      EDOD2.IdExpedienteDocumentoOrigenDestino = EDOD.IdExpedienteDocumentoOrigenDestino
            ) THEN 1 ELSE 0 END AS EsPropio
        ) ESPRES
        OUTER APPLY(
            SELECT CASE WHEN EXISTS (
                SELECT 1 FROM Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' edod3
                WHERE edod3.IdExpedienteDocumentoOrigenDestinoAnterior = EDOD.IdExpedienteDocumentoOrigenDestino
                    AND edod3.EstadoAuditoria = 1
                    AND edod3.FechaDestinoRecepciona IS NOT NULL
                    AND edod3.FechaDestinoRecepciona <> ''''
            ) THEN 0 ELSE 1 END AS EsExtornable
        ) ESEXTOR
		WHERE   E.IdExpediente = @pIdExpediente
 			AND EDOD.IdPersonaDestino= @pIdPersona AND EDOD.IdCargoDestino= @pIdCargo AND EDOD.IdAreaDestino= @pIdArea AND EDOD.IdEmpresaDestino= @pIdEmpresa
 			AND ED.CorrelativoVinculado= CASE WHEN @pCorrelativoVinculado>0 THEN @pCorrelativoVinculado ELSE ED.CorrelativoVinculado END
		ORDER BY CONVERT(DATETIME,edo.FechaOrigen +'' '' + edo.HoraOrigen) DESC, EDOD.IdExpedienteDocumentoOrigenDestino DESC
		OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
		FETCH NEXT @pDimensionPagina ROWS ONLY'

		EXEC sp_executesql @sql,
            N'@vSiPariticipo int, @vEsJefe int,@pIdEmpresa int,@pIdArea int,@pIdCargo int,@pIdPersona int,@vIdPersonaActual int,
            @pIdExpediente int,@pCorrelativoVinculado int,@pNumeroPagina int,@pDimensionPagina int',
            @vSiPariticipo = @vSiPariticipo,
            @vEsJefe = @vEsJefe,
            @pIdEmpresa = @pIdEmpresa,
            @pIdArea = @pIdArea,
            @pIdCargo = @pIdCargo,
            @pIdPersona = @pIdPersona,
            @vIdPersonaActual = @vIdPersonaActual,
            @pIdExpediente = @pIdExpediente,
            @pCorrelativoVinculado = @pCorrelativoVinculado,
            @pNumeroPagina = @pNumeroPagina,
            @pDimensionPagina = @pDimensionPagina

	END ELSE BEGIN
		select @sql = N'
	    insert into #tmp001_expedientePrueba SELECT case when ED.FgEnEsperaFirmaDigital=1 and Ver.doc=0 then 0 else @vSiPariticipo end SiPariticipo,
		Seguridad.funObtenerUsuario(edo.IdUsuarioCreacionAuditoria)Logueo,PTAD.PaseTieneAdjunto,DTAD.DocumentoTieneAdjunto,
		CONCAT(SD.AbreviaturaSerieDocumentalExpediente, RIGHT(1000000+E.NumeroExpediente,6), ''-'', E.IdPeriodo,
		    CASE WHEN COALESCE(ED.CorrelativoVinculado,0)=0 THEN '''' ELSE '' V-''+CONVERT(VARCHAR,ED.CorrelativoVinculado) END) NombreExpediente,
		ED.CorrelativoVinculado, EDO.EsVinculado, E.ExpedienteAnulado,E.IdExpediente,ED.IdExpedienteDocumento,
        EDOD.IdExpedienteDocumentoOrigenDestino, EDOD.IdExpedienteDocumentoOrigen,
        CASE WHEN EE.IdEnvio IS NULL THEN EDOD.IdCatalogoSituacionMovimientoDestino
		ELSE CASE WHEN EE.IdCatalogoSituacionEnvio = 14 THEN EDOD.IdCatalogoSituacionMovimientoDestino
		    ELSE EE.IdCatalogoSituacionEnvio END END IdCatalogoSituacionMovimientoDestino,
        CASE WHEN EE.IdEnvio IS NULL THEN CSM.Descripcion ELSE CASE WHEN EE.IdCatalogoSituacionEnvio = 14 THEN CSM.Descripcion
            ELSE CSMEE.Descripcion END END CatalogoSituacionMovimientoDestino,
        EDOD.IdCatalogoTipoMovimientoDestino, CTM.Descripcion CatalogoTipoMovimientoDestino,
        COALESCE(EDO.IdCatalogoTipodevolucion,0) IdCatalogoTipoDevolucion, EDOD.NumeroDiasAtencionSolicitado,
        COALESCE(EDOD.FechaDestinoRecepciona,'''')FechaDestinoRecepciona,
        COALESCE(EDOD.HoraDestinoRecepciona,'''')HoraDestinoRecepciona,
		COALESCE(EMO.NombreEmpresa,'''') NombreEmpresaOrigen,
		COALESCE(AO.NombreArea,'''') NombreAreaOrigen,
        CASE WHEN CTEO.IdCatalogo=9 THEN ''(LOCADOR)'' ELSE COALESCE(CO.NombreCargo,'''') END NombreCargoOrigen,
		CASE WHEN EDO.IdPersonaOrigen=0 THEN EDO.NombreCompletoOrigen ELSE
		CASE WHEN CTM.IdCatalogo=71 THEN coalesce(EDO.NombreCompletoOrigen,'''')  ELSE coalesce(PO.NombreCompleto,'''') END END  NombrePersonaOrigen,
		COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDO.IdPersonaOrigen),''sinfotoH.jpg'') RutaFotoPersona,
		COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),''sinfotoH.jpg'') RutaFotoPersonaDestino,
		EDOD.NumeroDiasAtencionAceptado,EDOD.Original,
		CASE WHEN E.IdCatalogoTipoTramite IN (211,477,478,129,391) THEN 211 ELSE E.IdCatalogoTipoTramite  END IdCatalogoTipoTramite,
        EDOD.Copia,EDOD.FechaDestino,EDOD.HoraDestino,EDO.FechaOrigen,EDO.HoraOrigen,
        COALESCE(EDOD.FechaDestinoEnvia,'''') FechaDestinoEnvia,COALESCE(EDOD.HoraDestinoEnvia,'''') HoraDestinoEnvia,
		COALESCE(EMD.NombreEmpresa,COALESCE(EDOD.DestinatarioDestino,'''')) NombreEmpresaDestino,
        COALESCE(AD.NombreArea,'''') NombreAreaDestino,
		CASE WHEN CTED.IdCatalogo=9 THEN ''(LOCADOR)'' ELSE COALESCE(CD.NombreCargo,'''') END NombreCargoDestino,
		COALESCE(Seguridad.funObtenerRutaFotoPorIdPersona(EDOD.IdPersonaDestino),''sinfotoH.jpg'') RutaFotoPersonaDestino,
        COALESCE(PD.NombreCompleto,'''') NombrePersonaDestino,
        COALESCE(EMR.NombreEmpresa,''EXTERNO'') NombreEmpresaDestinoRecepciona,
        COALESCE(AR.NombreArea,'''') NombreAreaDestinoRecepciona,
        COALESCE(CR.NombreCargo,'''') NombreCargoDestinoRecepciona,
        COALESCE(PR.NombreCompleto,'''') NombrePersonaDestinoRecepciona,
        COALESCE(EMA.NombreEmpresa,''EXTERNO'') NombreEmpresaDestinoAtencion,
        COALESCE(AA.NombreArea,'''') NombreAreaDestinoAtencion,
        COALESCE(CA.NombreCargo,'''') NombreCargoDestinoAtencion,
        COALESCE(PA.NombreCompleto,'''') NombrePersonaDestinoAtencion,
        COALESCE(EDOD.ObservacionesDestinatario,'''') ObservacionesDestinatario,MAXDES.Acciones,ED.IdExpedienteDocumento,
        CASE WHEN @vEsJefe=1 THEN 0 ELSE ESPRES.EsPropio END EsPropio,
		CASE WHEN @vEsJefe=1 THEN 0 ELSE
		    CASE WHEN ED.IdCargoEmisor=@pIdCargo and ED.IdAreaEmisor=@pIdArea and ED.IdEmpresaEmisor=@pIdEmpresa and ED.IdPersonaEmisor=@pIdPersona THEN 1 ELSE 0 END END EsMiDocumento,
		CASE WHEN @vEsJefe=1 THEN 0 ELSE
		    CASE WHEN EDO.IdCargoOrigen=@pIdCargo and EDO.IdAreaOrigen=@pIdArea and EDO.IdEmpresaOrigen=@pIdEmpresa and EDO.IdPersonaOrigen=@pIdPersona THEN 1 ELSE 0 END END EsOrigen,
        ED.IdExpedienteDocumento,CTD.Descripcion CatalogoTipoDocumento,
        CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,'' '', COALESCE(ED.NumeroDocumento,''''))
            ELSE COALESCE(ED.NumeroDocumento,'''') END  NumeroDocumento,
        COALESCE(ED.AsuntoDocumento,'''') AsuntoDocumento,
        COALESCE(ED.RutaArchivoDocumento,'''') RutaArchivoDocumento,
		isnull(FORMAT(ED.FechaCreacionAuditoria, ''dd/MM/yyyy HH:mm''),'''') FechaCreacionAuditoria,
        COALESCE(EDOD.FechaArchivado,'''')FechaArchivado,ESEXTOR.EsExtornable,EDOD.EsInicial,
		COALESCE(EDO.Descripciondevolucion,'''') DescripcionDevolucion,
		COALESCE(EDOD.MotivoArchivado,'''')MotivoArchivado,
		COALESCE(EE.FechaEntregaDocumento,'''')FechaEntregaDocumento,
		COALESCE(EE.HoraEntregaDocumento,'''')HoraEntregaDocumento,
		COALESCE(EE.RutaArchivoCargo,'''')RutaArchivoCargo,
		ED.FgEsObligatorioFirmaDigital,ED.FgEnEsperaFirmaDigital,ED.FlagParaDespacho,
		COALESCE(CASE WHEN YEAR(DATEADD(MONTH,-1,EE.FechaCreacionAuditoria))=YEAR(GETDATE()) THEN ''''
		ELSE CONVERT(VARCHAR, YEAR(DATEADD(MONTH,-1,EE.FechaCreacionAuditoria))) END,'''') PeriodoCreadoDocumento
        FROM Tramite.Expediente_Historico_' + @vIdPeriodo + N' E
        INNER JOIN Tramite.ExpedienteDocumento_Historico_' + @vIdPeriodo + N' ED
            ON ED.IdExpediente=E.IdExpediente
        INNER JOIN Tramite.ExpedienteDocumentoOrigen_Historico_' + @vIdPeriodo + N' EDO
            ON  EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND ED.EstadoAuditoria=1
        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD
            ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDO.EstadoAuditoria=1 AND EDOD.EstadoAuditoria=1
        INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
        INNER JOIN Tramite.Catalogo CSM ON CSM.IdCatalogo=EDOD.IdCatalogoSituacionMovimientoDestino
        INNER JOIN Tramite.Catalogo CTM ON CTM.IdCatalogo=EDOD.IdCatalogoTipoMovimientoDestino
		INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente = E.IdSerieDocumentalExpediente
		OUTER APPLY(
			select isnull(max(1),0) doc
			from Tramite.ExpedienteDocumentoFirmante_Historico_' + @vIdPeriodo + N' EDF
			where EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.IdPersona=@vIdPersonaActual and EDF.EstadoAuditoria=1
		) Ver
        LEFT JOIN General.Empresa EMO ON EMO.IdEmpresa=EDO.IdEmpresaOrigen
        LEFT JOIN General.Empresa EMD ON EMD.IdEmpresa=EDOD.IdEmpresaDestino
        LEFT JOIN General.Empresa EMR ON EMR.IdEmpresa=EDOD.IdEmpresaDestinoRecepciona
        LEFT JOIN General.Area AO ON AO.IdArea= EDO.IdAreaOrigen
        LEFT JOIN General.Cargo CO ON CO.IdCargo=EDO.IdCargoOrigen
        LEFT JOIN General.Empresa EMA ON EMA.IdEmpresa=EDOD.IdEmpresaDestinoAtencion
        LEFT JOIN General.Area AD ON AD.IdArea= EDOD.IdAreaDestino
        LEFT JOIN General.Area AR ON AR.IdArea= EDOD.IdAreaDestinoRecepciona
        LEFT JOIN General.Area AA ON AA.IdArea= EDOD.IdAreaDestinoAtencion
        LEFT JOIN General.Cargo CD ON CD.IdCargo=EDOD.IdCargoDestino
        LEFT JOIN General.Cargo CR ON CR.IdCargo=EDOD.IdCargoDestinoRecepciona
        LEFT JOIN General.Cargo CA ON CA.IdCargo=EDOD.IdCargoDestinoAtencion
        LEFT JOIN RecursoHumano.Empleado EMPD ON EMPD.IdPersona=EDOD.IdPersonaDestino AND EMPD.EstadoAuditoria=1
        LEFT JOIN RecursoHumano.Empleado EMPO ON EMPO.IdPersona=EDO.IdPersonaOrigen AND EMPO.EstadoAuditoria=1
		LEFT JOIN General.Persona PD ON PD.IdPersona=EMPD.IdPersona AND PD.EstadoAuditoria=1
		LEFT JOIN General.Persona PO ON PO.IdPersona=EMPO.IdPersona AND PO.EstadoAuditoria=1
		LEFT JOIN General.Persona PR ON PR.IdPersona=EDOD.IdPersonaDestinoRecepciona
        LEFT JOIN General.Persona PA ON PA.IdPersona=EDOD.IdPersonaDestinoAtencion
		LEFT JOIN RecursoHumano.Catalogo CTED ON CTED.IdCatalogo=EMPD.IdCatalogoTipoEmpleado
		LEFT JOIN RecursoHumano.Catalogo CTEO ON CTEO.IdCatalogo=EMPO.IdCatalogoTipoEmpleado
		LEFT JOIN Courrier.Envio EE ON EE.IdExpedienteDocumentoOrigenDestino = EDOD.IdExpedienteDocumentoOrigenDestino AND EE.EstadoAuditoria=1 AND FgEntregado=0
		LEFT JOIN Courrier.Catalogo CSMEE ON CSMEE.IdCatalogo=EE.IdCatalogoSituacionEnvio
		OUTER APPLY(
    		SELECT COUNT(1) PaseTieneAdjunto
    		FROM Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_' + @vIdPeriodo + N' edoa1
    		WHERE edoa1.EstadoAuditoria=1 and edoa1.IdExpedienteDocumentoOrigenEDO=EDO.IdExpedienteDocumentoOrigen
		)PTAD
		OUTER APPLY(
            SELECT COUNT(1) DocumentoTieneAdjunto
    		FROM Tramite.ExpedienteDocumentoAdjunto_Historico_' + @vIdPeriodo + N' eda1
    		WHERE eda1.EstadoAuditoria=1 and eda1.IdExpedienteDocumento=ED.IdExpedienteDocumento
		)DTAD
		OUTER APPLY (
            SELECT STRING_AGG(RTRIM(CA1.Descripcion), '', '') WITHIN GROUP(ORDER BY A1.IdExpedienteDocumentoOrigenDestinoAccion) AS Acciones
            FROM Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_' + @vIdPeriodo + N' A1
            INNER JOIN Tramite.Catalogo CA1 ON CA1.IdCatalogo = A1.IdCatalogoTipoAccion
            WHERE A1.IdExpedienteDocumentoOrigenDestino = EDOD.IdExpedienteDocumentoOrigenDestino AND A1.EstadoAuditoria = 1
        ) MAXDES
        OUTER APPLY (
            SELECT CASE WHEN EXISTS (
                SELECT 1 FROM Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' EDOD2
                WHERE EDOD2.IdPersonaDestino = @pIdPersona AND
                      EDOD2.IdCargoDestino = @pIdCargo AND
                      EDOD2.IdAreaDestino = @pIdArea AND
                      EDOD2.IdEmpresaDestino = @pIdEmpresa AND
                      EDOD2.IdExpedienteDocumentoOrigenDestino = EDOD.IdExpedienteDocumentoOrigenDestino
            ) THEN 1 ELSE 0 END AS EsPropio
        ) ESPRES
		OUTER APPLY(
            SELECT CASE WHEN EXISTS (
                SELECT 1 FROM Tramite.ExpedienteDocumentoOrigenDestino_Historico_' + @vIdPeriodo + N' edod3
                WHERE edod3.IdExpedienteDocumentoOrigenDestinoAnterior = EDOD.IdExpedienteDocumentoOrigenDestino
                    AND edod3.EstadoAuditoria = 1
                    AND edod3.FechaDestinoRecepciona IS NOT NULL
                    AND edod3.FechaDestinoRecepciona <> ''''
            ) THEN 0 ELSE 1 END AS EsExtornable
        ) ESEXTOR
		WHERE   E.IdExpediente=@pIdExpediente AND ED.CorrelativoVinculado= CASE WHEN @pCorrelativoVinculado>0 THEN @pCorrelativoVinculado ELSE ED.CorrelativoVinculado END
		ORDER BY CONVERT(DATETIME,edo.FechaOrigen +'' '' + edo.HoraOrigen) DESC, EDOD.IdExpedienteDocumentoOrigenDestino DESC
		OFFSET (@pNumeroPagina-1)*@pDimensionPagina ROWS
		FETCH NEXT @pDimensionPagina ROWS ONLY'


  		EXEC sp_executesql @sql,
            N'@vSiPariticipo int, @vEsJefe int,@pIdEmpresa int,@pIdArea int,@pIdCargo int,@pIdPersona int,@vIdPersonaActual int,
            @pIdExpediente int,@pCorrelativoVinculado int,@pNumeroPagina int,@pDimensionPagina int',
            @vSiPariticipo = @vSiPariticipo,
            @vEsJefe = @vEsJefe,
            @pIdEmpresa = @pIdEmpresa,
            @pIdArea = @pIdArea,
            @pIdCargo = @pIdCargo,
            @pIdPersona = @pIdPersona,
            @vIdPersonaActual = @vIdPersonaActual,
            @pIdExpediente = @pIdExpediente,
            @pCorrelativoVinculado = @pCorrelativoVinculado,
            @pNumeroPagina = @pNumeroPagina,
            @pDimensionPagina = @pDimensionPagina

	END

	select
    SiPariticipo,
    Logueo,
    isnull(PaseTieneAdjunto,0) PaseTieneAdjunto,
    isnull(DocumentoTieneAdjunto,0) DocumentoTieneAdjunto,
    NombreExpediente,
    CorrelativoVinculado,
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
    IdCatalogoTipoDevolucion,
    NumeroDiasAtencionSolicitado,
    FechaDestinoRecepciona,
    HoraDestinoRecepciona,
    NombreEmpresaOrigen,
    NombreAreaOrigen,
    NombreCargoOrigen,
    NombrePersonaOrigen,
    RutaFotoPersona,
    RutaFotoPersonaDestino,
    NumeroDiasAtencionAceptado,
    Original,
    IdCatalogoTipoTramite,
    Copia,
    FechaDestino,
    HoraDestino,
    FechaOrigen,
    HoraOrigen,
    FechaDestinoEnvia,
    HoraDestinoEnvia,
    NombreEmpresaDestino,
    NombreAreaDestino,
    NombreCargoDestino,
    RutaFotoPersonaDestino,
    NombrePersonaDestino,
    NombreEmpresaDestinoRecepciona,
    NombreAreaDestinoRecepciona,
    NombreCargoDestinoRecepciona,
    NombrePersonaDestinoRecepciona,
    NombreEmpresaDestinoAtencion,
    NombreAreaDestinoAtencion,
    NombreCargoDestinoAtencion,
    NombrePersonaDestinoAtencion,
    ObservacionesDestinatario,
    isnull(Acciones,'') Acciones,
    IdExpedienteDocumento,
    isnull(EsPropio, 0) EsPropio,
    EsMiDocumento,
    EsOrigen,
    IdExpedienteDocumento,
    CatalogoTipoDocumento,
    NumeroDocumento,
    AsuntoDocumento,
    RutaArchivoDocumento,
    FechaCreacionAuditoria,
    FechaArchivado,
    isnull(EsExtornable, 1) EsExtornable,
    EsInicial,
    DescripcionDevolucion,
    MotivoArchivado,
    FechaEntregaDocumento,
    HoraEntregaDocumento,
    RutaArchivoCargo,
    FgEsObligatorioFirmaDigital,
    FgEnEsperaFirmaDigital,
    FlagParaDespacho,
    PeriodoCreadoDocumento
	from #tmp001_expedientePrueba

    select count(1) from #tmp001_expedientePrueba

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpediente',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO


exec tramite.paListarDocumentoPendienteEspecialistaV1_arq
@pIdExpediente = 570251,
@pIdEmpresa = 2,
@pIdArea = 79,
@pIdCargo = 272,
@pIdPersona = 1059,
@pIdUsuarioAuditoria = 1059,
@pCampoOrdenado = null,
@pTipoOrdenacion = null,
@pNumeroPagina = 1,
@pDimensionPagina = 10,
@pBusquedaGeneral = null,
@pVerSoloMio = 0,
@pCorrelativoVinculado = -1,
@pIdPeriodo = 2025


exec tramite.paListarDocumentoPendienteEspecialistaV1_arq
@pIdExpediente = 570251,
@pIdEmpresa = 2,
@pIdArea = 79,
@pIdCargo = 272,
@pIdPersona = 1059,
@pIdUsuarioAuditoria = 1059,
@pCampoOrdenado = null,
@pTipoOrdenacion = null,
@pNumeroPagina = 1,
@pDimensionPagina = 10,
@pBusquedaGeneral = null,
@pVerSoloMio = 0,
@pCorrelativoVinculado = -1,
@pIdPeriodo = 2026
