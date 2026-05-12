ALTER PROCEDURE [Tramite].[paListarExpedientePendienteJefaturaV8FosCad]
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
set tran isolation level read uncommitted
set nocount on

    DECLARE @vIdAreaJefe int=0, @vIdEmpresaJefe int=0, @vIdCargoJefe int=0,
        @iRegistroTotal Int, @iPaginaRegInicio Int, @iPaginaRegFinal Int

    SELECT Top 1
        @vIdAreaJefe = cp.IdArea,
        @vIdEmpresaJefe = ES.IdEmpresa
    FROM
        RecursoHumano.Empleado c WITH (NOLOCK)
        INNER JOIN RecursoHumano.EmpleadoPerfil cp WITH (NOLOCK) ON c.IdEmpleado = cp.IdEmpleado AND cp.EstadoAuditoria = 1 AND cp.Activo = 1
        INNER JOIN General.Cargo CA WITH (NOLOCK) ON CA.IdCargo = cp.IdCargo
        INNER JOIN General.Persona pe WITH (NOLOCK) ON pe.IdPersona = c.IdPersona
        INNER JOIN Seguridad.Usuario u WITH (NOLOCK) ON u.IdPersona = pe.IdPersona AND u.EstadoAuditoria = 1 AND u.Bloqueado = 0
        INNER JOIN General.Area a WITH (NOLOCK) ON a.IdArea = cp.IdArea
        INNER JOIN General.EmpresaSede ES WITH (NOLOCK) ON cp.IdEmpresaSede = ES.IdEmpresaSede
    WHERE (c.EstadoAuditoria = 1)
        AND (cp.EstadoAuditoria = 1)
        AND (cp.Activo = 1)
        AND (c.Activo = 1)
        AND (u.EsInstitucion = 1)
        AND CA.IdCatalogoTipoCargo IN (32,33,34)
        And cp.IdArea = @pIdArea

    SET LANGUAGE 'SPANISH'

    Create Table #vTablaExpediente(
        IdExpediente BigInt,
        FechaMovimiento Datetime,
        EsParaAnular int,
        DiasPendiente int,
        NombrePersonaOrigen varchar(max),
        NumeroDocumento varchar(max),
        IdExpedienteDocumento int,
        eNroOrden Int);

    Create Clustered Index vTablaExpediente_eNroOrden On #vTablaExpediente(eNroOrden)

    IF ISNUMERIC(@pBusquedaGeneral)=1 OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=''
    BEGIN
        if @pIdCatalogoSituacionMovimientoDestino=5
        begin
            INSERT INTO #vTablaExpediente(
                IdExpediente, FechaMovimiento, EsParaAnular, DiasPendiente, NombrePersonaOrigen, NumeroDocumento, IdExpedienteDocumento, eNroOrden)
            SELECT
                SE.IdExpediente,
                SE.FechaMovimiento,
                0 EsParaAnular,
                SE.DiasPendiente,
                '' As NombrePersonaOrigen,
                SE.NumeroDocumento,
                SE.IdExpedienteDocumento,
                Row_Number() Over(Order By SE.FechaMovimiento DESC) As eNroOrden
            FROM(
                SELECT
                    E.IdExpediente,
                    MAX(CONVERT(DATETIME,edod.FechaDestinoEnvia +' ' + edod.HoraDestinoEnvia)) FechaMovimiento,
                    MAX(CASE WHEN COALESCE(EDOD.FechaDestinoRecepciona,'')<>''
                        THEN DATEDIFF(DAY,CONVERT(DATE, EDOD.FechaDestinoRecepciona),GETDATE()) ELSE 0 end) DiasPendiente,
                    MAX('<button type="button" data-toggle="tooltip" title="'+
                    COALESCE(EDOD.MotivoArchivado,'')+
                    '" class="btn ui blue label" onclick="MostrarDocumentoPdfExp('''+
                    ED.RutaArchivoDocumento+
                    ''','+
                    CONVERT(VARCHAR,ED.IdExpedienteDocumento) +
                    ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:10px;line-height:13px;padding-top:6px;">'+
                    CASE WHEN ED.Correlativo=0 THEN  CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END+
                    '</label>') NumeroDocumento,
                    MAX(ED.IdExpedienteDocumento) IdExpedienteDocumento
                FROM Tramite.Expediente E WITH (NOLOCK)
			        INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK)
				ON  E.IdExpediente=ED.IdExpediente
				AND ED.EstadoAuditoria=E.EstadoAuditoria
			        INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
				ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento
				AND EDO.EstadoAuditoria=E.EstadoAuditoria
			        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
				ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen
				AND EDOD.EstadoAuditoria=E.EstadoAuditoria
                    INNER JOIN General.Cargo CAR WITH (NOLOCK)
                        ON CAR.IdCargo = EDOD.IdCargoDestino
                        AND CAR.IdCatalogoTipoCargo in (32,33,34)
                    LEFT JOIN Tramite.Catalogo CTD
                        ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
                WHERE E.EstadoAuditoria = 1
                    AND E.ExpedienteAnulado=0
                    AND EDOD.IdAreaDestino=@vIdAreaJefe
                    AND EDOD.IdEmpresaDestino=@vIdEmpresaJefe
                    AND EDOD.IdCatalogoSituacionMovimientoDestino=@pIdCatalogoSituacionMovimientoDestino
                    AND (E.NumeroExpediente = @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)
                GROUP BY E.IdExpediente
            ) SE
        end
        Else If @pIdCatalogoSituacionMovimientoDestino=6 or @pIdCatalogoSituacionMovimientoDestino=3
        begin
            INSERT INTO #vTablaExpediente(
                IdExpediente, FechaMovimiento, EsParaAnular, DiasPendiente, NombrePersonaOrigen, NumeroDocumento, IdExpedienteDocumento, eNroOrden)
            SELECT
                SE.IdExpediente,
                SE.FechaMovimiento,
                0 EsParaAnular,
                0 DiasPendiente,
                '' As NombrePersonaOrigen,
                SE.NumeroDocumento,
                SE.IdExpedienteDocumento,
                Row_Number() Over(Order By SE.FechaMovimiento DESC) As eNroOrden
            FROM(
                SELECT
                    E.IdExpediente,
                    MAX(CONVERT(DATETIME,edod.FechaDestinoEnvia +' ' + edod.HoraDestinoEnvia)) FechaMovimiento,
                    MAX('<button type="button" data-toggle="tooltip" class="btn ui blue label" onclick="MostrarDocumentoPdfExp('''+
                    ED.RutaArchivoDocumento+''','+
                    CONVERT(VARCHAR,ED.IdExpedienteDocumento) +
                    ')"><i style="font-size:16px;" class="fa fa-file-text"></i></button><label style="font-size:8px;line-height:13px;padding-top:6px;">'+
                    CASE WHEN ED.Correlativo=0
                        THEN  CONCAT( CTD.Descripcion,' ', COALESCE(ED.NumeroDocumento,'')) ELSE COALESCE(ED.NumeroDocumento,'') END+
                    '</label>') NumeroDocumento,
                    MAX(ED.IdExpedienteDocumento) IdExpedienteDocumento
                FROM Tramite.Expediente E WITH (NOLOCK)
			        INNER JOIN Tramite.ExpedienteDocumento ED WITH (NOLOCK)
						ON  E.IdExpediente=ED.IdExpediente
						AND ED.EstadoAuditoria=E.EstadoAuditoria
			        INNER JOIN Tramite.ExpedienteDocumentoOrigen EDO WITH (NOLOCK)
						ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento
						AND EDO.EstadoAuditoria=E.EstadoAuditoria
			        INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
						ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen
						AND EDOD.EstadoAuditoria=E.EstadoAuditoria
                    INNER JOIN General.Cargo CAR WITH (NOLOCK)
                        ON CAR.IdCargo = EDOD.IdCargoDestino
                        AND CAR.IdCatalogoTipoCargo in (32,33,34)
                    LEFT JOIN Tramite.Catalogo CTD
                        ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
                WHERE E.EstadoAuditoria = 1
                    AND E.ExpedienteAnulado=0
                    AND EDOD.IdAreaDestino=@vIdAreaJefe
                    AND EDOD.IdEmpresaDestino=@vIdEmpresaJefe
                    AND EDOD.IdCatalogoSituacionMovimientoDestino=@pIdCatalogoSituacionMovimientoDestino
                    AND (E.NumeroExpediente =  @pBusquedaGeneral OR @pBusquedaGeneral IS NULL OR @pBusquedaGeneral=0)
                GROUP BY E.IdExpediente
            ) SE
        end
    END

	Begin
		SELECT @iRegistroTotal = Count(1) From #vTablaExpediente

		SELECT @iPaginaRegInicio = c.iStartRow,
			@iPaginaRegFinal = c.iEndrow
		FROM General.fnObtenerPaginacion(@pDimensionPagina, @pNumeroPagina, @iRegistroTotal) c
	End

    select
        convert(varchar, @iRegistroTotal)+'¦'+
        (select STUFF((
                    SELECT
                        '¬'+convert(varchar,tE.EsParaAnular),
                        '|'+convert(varchar,tE.DiasPendiente),
                        '|'+tE.NombrePersonaOrigen,
                        '|'+replace(tE.NumeroDocumento,'|',''),
                        '|'+convert(varchar,tE.IdExpedienteDocumento),
                        '|'+CASE WHEN ENP.ExEnlazadoPri<>'' THEN ENP.ExEnlazadoPri else ENS.ExEnlazadoSec END,
                        '|'+CASE WHEN EE.cantEnlaces>0 THEN '1' ELSE '0' END,
                        '|'+OID.CatalogoTipoOrigen,
                        '|'+convert(varchar,E.IdExpediente),
                        '|'+convert(varchar,E.ExpedienteConfidencial),
                        '|'+E.NTFechaExpediente,
                        '|'+E.HoraExpediente,
                        '|'+convert(varchar,E.IdCatalogoTipoPrioridad),
                        '|'+COALESCE(CTP.Descripcion,''),
                        '|'+COALESCE(CTT.Descripcion,''),
                        '|'+COALESCE(CTT.Detalle,''),
                        '|'+US.Logueo,
                        '|'+case when COALESCE(SFU.RutaArchivoFoto,'') ='' then
                            CASE WHEN COALESCE(PE.Sexo,0)=0 then 'sinfotoH.jpg' else 'sinfotoM.jpg' end else SFU.RutaArchivoFoto end,
                        '|'+replace(UPPER(E.AsuntoExpediente),'|',' '),
                        '|'+convert(varchar,COALESCE(E.NumeroFoliosExpediente,0)),
                        '|'+COALESCE(replace(E.ObservacionesExpediente,'|',' '),''),
                        '|'+CONCAT(E.NTFechaExpediente ,' ', E.HoraExpediente),
                        '|'+E.NombreExpediente,
                        '|'+CASE WHEN COALESCE(E.NombreCompletoCreador,'')<>'' THEN COALESCE(E.NombreCompletoCreador,'') ELSE PE.NombreCompleto END,
                        '|'+convert(varchar,E.NumeroExpediente),
                        '|'+convert(varchar,COALESCE(ES.IdExpedienteSeguimiento, 0 )),
                        '|'+isnull(FORMAT(tE.FechaMovimiento, 'dd/MM/yyyy HH:mm'),'')
                    FROM #vTablaExpediente tE
                INNER JOIN Tramite.Expediente E WITH (NOLOCK) ON tE.IdExpediente=E.IdExpediente
                INNER JOIN Seguridad.Usuario US ON US.IdUsuario=E.IdUsuarioCreacionAuditoria
                INNER JOIN Tramite.Catalogo CTP ON CTP.IdCatalogo=E.IdCatalogoTipoPrioridad
                INNER JOIN Tramite.Catalogo CTT ON CTT.IdCatalogo=E.IdCatalogoTipoTramite
                LEFT JOIN General.Persona PE ON PE.IdPersona=E.IdPersonaCreador
                OUTER APPLY(
                    SELECT TOP 1 FU.RutaArchivoFoto
                    FROM Seguridad.Usuario FU
                    WHERE FU.IdPersona = PE.IdPersona
                        And FU.EstadoAuditoria=1
                        AND FU.Bloqueado=0
                    ORDER BY FU.RutaArchivoFoto DESC
                ) SFU
                LEFT JOIN Tramite.ExpedienteSeguimiento ES WITH (NOLOCK)
                    ON ES.IdExpediente= E.IdExpediente
                    AND ES.EstadoAuditoria=1
                    AND ES.IdCargo=0
                    AND ES.IdPersona=0
                    AND ES.IdArea=@pIdArea
                CROSS APPLY(
                    SELECT count(ee.Idexpediente) cantEnlaces
                    FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
                    where EE.IdExpedienteSecundario=E.IdExpediente And EE.IdExpediente=E.IdExpediente
                ) EE
                CROSS APPLY(
                    select top 1 CONCAT(coalesce(c.Descripcion,''),' ',E.NumeroExpedienteExterno) CatalogoTipoOrigen
                    from Tramite.ExpedienteDocumento ed1  WITH (NOLOCK)
                    INNER JOIN Tramite.Catalogo c on c.IdCatalogo=ed1.IdCatalogoTipoOrigen
                    where ed1.EstadoAuditoria=1 and ed1.IdExpediente=E.IdExpediente
                    order by ed1.IdExpedienteDocumento
                ) OID
                CROSS APPLY(
                    select isnull((select STUFF((
                    SELECT '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
                    E.NombreExpediente
                    +'</div>'
                    FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
                    where EE.IdExpediente=E.IdExpediente
                    FOR XML PATH('')), 1, 0, '')),'') ExEnlazadoPri
                ) ENP
                CROSS APPLY(
                    select isnull((select STUFF((
                    SELECT '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
                    E.NombreExpediente
                    +'</div>'
                    FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
                    WHERE EE.IdExpedienteSecundario=E.IdExpediente
                    FOR XML PATH('')), 1, 0, '')),'') ExEnlazadoSec
                ) ENS
                WHERE tE.eNroOrden Between @iPaginaRegInicio And @iPaginaRegFinal
                ORDER BY tE.eNroOrden ASC
            FOR XML PATH('')), 1, 1, '')
         )

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() , @ERROR_PROCEDURE='Tramite.paListarExpedientePendienteJefaturaV8',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE, @pIdUsuarioAuditoria
END CATCH
END
GO
