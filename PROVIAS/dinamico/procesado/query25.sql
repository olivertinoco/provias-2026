CREATE OR ALTER PROCEDURE Tramite.paListarExpedienteAcervoDocumentalExportarExcelJefaturaV1_arq
    @pIdAreaEmisor INT,
    @pIdPersona INT,
    @pIdUsuarioAuditoria int,
    @pIdPeriodo int,
    @pIdCatalogoTipoDocumento int,
    @pAsuntoDocumento varchar(500),
    @pNumeroDocumento varchar(100),
    @pFechaDocumento varchar(30)
AS
BEGIN
BEGIN TRY
set nocount on
set tran isolation level read uncommitted

if @pIdPeriodo = 0 or @pIdPeriodo is null begin
    RAISERROR('El periodo no debe ser 0 o vacio', 10, 1) with nowait;
    return;
end

create table #tmp001_expedienteDocumento(
    Periodo int,
    TipoDocumento varchar(400) collate database_default,
    Expediente varchar(29) collate database_default,
    ExpedienteAnulado bit,
    NombreEmpresa varchar(500) collate database_default,
    NombreArea varchar(500) collate database_default,
    NombreCargo varchar(200) collate database_default,
    NombreCompleto varchar(400) collate database_default,
    NumeroDocumento varchar(200) collate database_default,
    NFechaDocumento varchar(10) collate database_default,
    AsuntoDocumento varchar(8000) collate database_default,
    ObservacionesDocumento varchar(4000) collate database_default,
    Correlativo int,
    Destinatario varchar(max) collate database_default,
    Logueo varchar(100) collate database_default
)

	declare @vFechaInicial varchaR(10)
	declare @vFechaFinal varchaR(10)

	declare @vSql Nvarchar(max)=''
	declare @vAnno int = year(getdate())
    declare @vcExpedienteRpta Nvarchar(100) = ''
    select @vcExpedienteRpta = case @vAnno when @pIdPeriodo then '' else concat('_historico_', @pIdPeriodo) end

	IF COALESCE(@pFechaDocumento,'')<>''
	begin
		SET @vFechaInicial=left(@pFechaDocumento,10)
		SET @vFechaFinal=RIGHT(@pFechaDocumento,10)
		if @vFechaInicial=@vFechaFinal
		begin
			set @pFechaDocumento=''
		end
	end
    set language spanish

    declare @vFechaInicial2 date = @vFechaInicial, @vFechaFinal2 date = @vFechaFinal

    select @vSql = N'\
	insert into #tmp001_expedienteDocumento SELECT DISTINCT
	year(ED.NFechaDocumento),CTD.Descripcion,CONCAT(SD.AbreviaturaSerieDocumentalExpediente, RIGHT(1000000+E.NumeroExpediente,6), ''-'', E.IdPeriodo),
	E.ExpedienteAnulado,EM.NombreEmpresa,A.NombreArea,C.NombreCargo,P.NombreCompleto,ED.NumeroDocumento,ED.NFechaDocumento,ED.AsuntoDocumento,ED.ObservacionesDocumento,ED.Correlativo,DEST.Destinatario,u.Logueo
	FROM Tramite.Expediente'+@vcExpedienteRpta+N' E
	INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
	INNER JOIN Tramite.ExpedienteDocumento'+@vcExpedienteRpta+N' ED ON ED.IdExpediente=E.IdExpediente AND ED.EstadoAuditoria=1
	INNER JOIN Tramite.ExpedienteDocumentoOrigen'+@vcExpedienteRpta+N' EDO ON EDO.IdExpedienteDocumento=ED.IdExpedienteDocumento AND EDO.EstadoAuditoria=1
	INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino'+@vcExpedienteRpta+N' EDOD ON EDOD.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDOD.EsInicial<>0
	INNER JOIN Tramite.Catalogo CTD ON CTD.IdCatalogo=ED.IdCatalogoTipoDocumento
	LEFT JOIN General.Cargo C ON C.IdCargo=ED.IdCargoEmisor
	LEFT JOIN General.Area A ON A.IdArea=ED.IdAreaEmisor
	LEFT JOIN General.Empresa EM ON EM.IdEmpresa=ED.IdEmpresaEmisor
	LEFT JOIN General.Persona P ON P.IdPersona=ED.IdPersonaEmisor
	LEFT JOIN Seguridad.Usuario U on U.IdUsuario=E.IdUsuarioCreacionAuditoria
	OUTER APPLY(
        SELECT TOP 1
  		COALESCE(EDOD.DestinatarioDestino,concat(P.NombreCompleto,'' '',isnull(EM.NombreEmpresa,''EXTERNO''),'' '',A.NombreArea,'' '',C.NombreCargo)) Destinatario
  		FROM Tramite.ExpedienteDocumentoOrigenDestino'+@vcExpedienteRpta+N' EDOD2
  		LEFT JOIN General.Cargo C ON C.IdCargo=EDOD2.IdCargoDestino
  		LEFT JOIN General.Area A ON A.IdArea=EDOD2.IdAreaDestino
  		LEFT JOIN General.Empresa EM ON EM.IdEmpresa=EDOD2.IdEmpresaDestino
  		LEFT JOIN General.Persona P ON P.IdPersona=EDOD2.IdPersonaDestino
  		WHERE EDOD2.IdExpedienteDocumentoOrigen=EDO.IdExpedienteDocumentoOrigen AND EDOD2.EsInicial<>0 and EDOD2.EstadoAuditoria=1
	)DEST
	WHERE EDOD.EstadoAuditoria=1 AND (@pIdCatalogoTipoDocumento=0 or ED.IdCatalogoTipoDocumento = @pIdCatalogoTipoDocumento) AND ED.IdAreaEmisor=@pIdAreaEmisor AND (@pIdPersona=0 OR ED.IdPersonaEmisor=@pIdPersona)
	AND (@pFechaDocumento='''' OR convert(date, NFechaDocumento) between @vFechaInicial2 and @vFechaFinal2) and year(ED.NFechaDocumento) = @pIdPeriodo'

	exec sp_executesql @vSql, N'@pIdCatalogoTipoDocumento int, @pIdAreaEmisor int, @pIdPersona int, @pFechaDocumento varchar(30), @vFechaInicial2 date, @vFechaFinal2 date, @pIdPeriodo int',
	@pIdCatalogoTipoDocumento = @pIdCatalogoTipoDocumento, @pIdAreaEmisor = @pIdAreaEmisor, @pIdPersona = @pIdPersona,
	@pFechaDocumento = @pFechaDocumento, @vFechaInicial2 = @vFechaInicial2, @vFechaFinal2 = @vFechaFinal2, @pIdPeriodo = @pIdPeriodo

	select
        Periodo,
        TipoDocumento [Tipo Documento],
        Expediente,
        CASE WHEN ExpedienteAnulado=0 THEN 'NO' ELSE 'SI' END Anulado,
        isnull(NombreEmpresa,'EXTERNO') [Razon Social],
        isnull(NombreArea,'') [Nombre Area],
        isnull(NombreCargo,'') [Nombre Cargo],
        isnull(NombreCompleto,'') [Nombre Completo],
        isnull(NumeroDocumento,'') Documento,
        NFechaDocumento [Fecha documento],
        upper(isnull(AsuntoDocumento,'')) Asunto,
        isnull(ObservacionesDocumento,'') Observaciones,
        isnull(Destinatario,'') Destinatario,
        Logueo
    from #tmp001_expedienteDocumento
    where (@pAsuntoDocumento='' or AsuntoDocumento LIKE '%'+@pAsuntoDocumento+'%') AND (@pNumeroDocumento='' or NumeroDocumento LIKE '%'+@pNumeroDocumento+'%')
    order by TipoDocumento, isnull(Correlativo,'')

END TRY
BEGIN CATCH
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX) ,@ERROR_MESSAGE VARCHAR(MAX)
    SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE() ,
    @ERROR_PROCEDURE='Tramite.paListarExpedienteAcervoDocumentalExportarExcelJefaturaV1_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
    EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO




-- execute Tramite.paListarExpedienteAcervoDocumentalExportarExcelJefaturaV1_arq 30,0,53721,2025,0,'','', '01/07/2025 - 08/07/2026' --PERFIL JEFE
-- execute [bd_sgd_arq].Tramite.paListarExpedienteAcervoDocumentalExportarExcelJefaturaV1 30,0,53721,2025,0,'','', '01/07/2025 - 08/07/2026' --PERFIL JEFE
-- return

execute [Tramite].paListarExpedienteAcervoDocumentalExportarExcelJefaturaV1_arq 79,0,349,2025,0,'','', '01/07/2025 - 08/07/2026' --PERFIL JEFE
execute [Tramite].paListarExpedienteAcervoDocumentalExportarExcelJefaturaV1_arq 79,0,39212,2026,0,'','', '01/07/2025 - 08/07/2026' --PERFIL SECRETARIA
