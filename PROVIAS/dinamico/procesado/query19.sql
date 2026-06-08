alter PROCEDURE [Tramite].[paObtenerExpedienteDocumentoOrigenDestino_arq]
    @pIdExpedienteDocumentoOrigenDestino INT,
	@pIdPeriodo int
AS
BEGIN
BEGIN TRY
set nocount on
set tran isolation level read uncommitted

declare @vAnno int = year(getdate()), @vExpediente varchar(50)='', @vSql Nvarchar(max)
if(@pIdPeriodo != @vAnno) select @vExpediente = concat('_historico_',@pIdPeriodo)

create table #tmp001_expediente765(
    NumeroDiasAtencionSolicitado int,
    IdExpediente int,
    IdExpedienteDocumentoOrigenDestino int,
    IdExpedienteDocumentoOrigen int,
    IdExpedienteDocumento int,
    IdCatalogoSituacionMovimientoDestino int,
    IdCatalogoTipoMovimientoDestino int,
    Original bit,
    Copia bit,
    FechaDestino varchar(10) collate database_default,
    HoraDestino varchar(5) collate database_default,
    IdEmpresaDestinoRecepciona int,
    IdAreaDestinoRecepciona int,
    IdCargoDestinoRecepciona int,
    IdPersonaDestinoRecepciona int,
    IdEmpresaDestino int,
    IdAreaDestino int,
    IdCargoDestino int,
    IdPersonaDestino int,
    IdEmpresaDestinoAtencion int,
    IdAreaDestinoAtencion int,
    IdCargoDestinoAtencion int,
    IdPersonaDestinoAtencion int,
    IdEstanteArchivador int,
    ObservacionesDestinatario varchar(4000) collate database_default,
    AbreviaturaSerieDocumentalExpediente varchar(10) collate database_default,
    NumeroExpediente int,
    IdPeriodo int,
    CorrelativoVinculado int,
    ObservacionesDocumento varchar(4000) collate database_default,
    AsuntoExpediente varchar(8000) collate database_default,
    IdCatalogoTipoTramite int,
    NTFechaExpediente varchar(10) collate database_default,
    plazoInicial int
)

    select @vSql=N'\
	insert into #tmp001_expediente765 SELECT
	EDOD.NumeroDiasAtencionSolicitado,
	E.IdExpediente,
	EDOD.IdExpedienteDocumentoOrigenDestino,
	EDOD.IdExpedienteDocumentoOrigen,
	ED.IdExpedienteDocumento,
	EDOD.IdCatalogoSituacionMovimientoDestino,
	EDOD.IdCatalogoTipoMovimientoDestino,
	EDOD.Original,
	EDOD.Copia,
	EDOD.FechaDestino,
	EDOD.HoraDestino,
	EDOD.IdEmpresaDestinoRecepciona,
	EDOD.IdAreaDestinoRecepciona,
	EDOD.IdCargoDestinoRecepciona,
	EDOD.IdPersonaDestinoRecepciona,
	EDOD.IdEmpresaDestino,
	EDOD.IdAreaDestino,
	EDOD.IdCargoDestino,
	EDOD.IdPersonaDestino,
	EDOD.IdEmpresaDestinoAtencion,
	EDOD.IdAreaDestinoAtencion,
	EDOD.IdCargoDestinoAtencion,
	EDOD.IdPersonaDestinoAtencion,
	EDOD.IdEstanteArchivador,
	EDOD.ObservacionesDestinatario,
	SD.AbreviaturaSerieDocumentalExpediente,
	E.NumeroExpediente,
	E.IdPeriodo,
    ED.CorrelativoVinculado,
	ED.ObservacionesDocumento,
	E.AsuntoExpediente,
	E.IdCatalogoTipoTramite,
	E.NTFechaExpediente,
	PLZ.plazoInicial
	FROM Tramite.ExpedienteDocumentoOrigenDestino'+ @vExpediente +N' EDOD
	INNER JOIN Tramite.ExpedienteDocumentoOrigen'+ @vExpediente +N' EDO ON EDO.IdExpedienteDocumentoOrigen=EDOD.IdExpedienteDocumentoOrigen and EDO.EstadoAuditoria=1
	INNER JOIN Tramite.ExpedienteDocumento'+ @vExpediente +N' ED ON ED.IdExpedienteDocumento=EDO.IdExpedienteDocumento AND ED.EstadoAuditoria=1
	INNER JOIN Tramite.Expediente'+ @vExpediente +N' E ON E.IdExpediente=ED.IdExpediente
	INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente
	OUTER APPLY(
        select top 1 EDOD2.NumeroDiasAtencionSolicitado plazoInicial
        FROM Tramite.ExpedienteDocumentoOrigenDestino'+ @vExpediente +N' EDOD2
        INNER JOIN Tramite.ExpedienteDocumentoOrigen'+ @vExpediente +N' EDO2 ON EDO2.IdExpedienteDocumentoOrigen=EDOD2.IdExpedienteDocumentoOrigen and EDO2.EstadoAuditoria=1 and EDOD2.EstadoAuditoria=1
        INNER JOIN Tramite.ExpedienteDocumento'+ @vExpediente +N' ED2 ON ED2.IdExpedienteDocumento=EDO2.IdExpedienteDocumento AND ED2.EstadoAuditoria=1
        where ED2.IdExpediente=E.IdExpediente order by EDOD2.IdExpedienteDocumentoOrigenDestino asc
	)PLZ
	WHERE EDOD.IdExpedienteDocumentoOrigenDestino=@pIdExpedienteDocumentoOrigenDestino AND EDOD.EstadoAuditoria=1'

	exec sp_executesql @vSql,
	    N'@pIdExpedienteDocumentoOrigenDestino int',
	    @pIdExpedienteDocumentoOrigenDestino=@pIdExpedienteDocumentoOrigenDestino

select
    case when t.IdCatalogoTipoTramite not in (211,477,478,129,391) then t.NumeroDiasAtencionSolicitado else fch.diasSabDom end NumeroDiasAtencionAceptado,
	t.IdExpedienteDocumentoOrigenDestino,
	t.IdExpedienteDocumentoOrigen,
	t.IdExpedienteDocumento,
	t.IdCatalogoSituacionMovimientoDestino,
	t.IdCatalogoTipoMovimientoDestino,
	t.Original,
	t.Copia,
	t.FechaDestino,
	t.HoraDestino,
	COALESCE(t.IdEmpresaDestinoRecepciona,0)IdEmpresaDestinoRecepciona,
	COALESCE(t.IdAreaDestinoRecepciona,0)IdAreaDestinoRecepciona,
	COALESCE(t.IdCargoDestinoRecepciona,0)IdCargoDestinoRecepciona,
	COALESCE(t.IdPersonaDestinoRecepciona,0)IdPersonaDestinoRecepciona,
	t.IdEmpresaDestino,
	t.IdAreaDestino,
	t.IdCargoDestino,
	t.IdPersonaDestino,
	COALESCE(t.IdEmpresaDestinoAtencion,0)IdEmpresaDestinoAtencion,
	COALESCE(t.IdAreaDestinoAtencion,0)IdAreaDestinoAtencion,
	COALESCE(t.IdCargoDestinoAtencion,0)IdCargoDestinoAtencion,
	COALESCE(t.IdPersonaDestinoAtencion,0)IdPersonaDestinoAtencion,
	COALESCE(t.IdEstanteArchivador,0)IdEstanteArchivador,
	COALESCE(t.ObservacionesDestinatario,'')ObservacionesDestinatario,
	CONCAT(t.AbreviaturaSerieDocumentalExpediente +RIGHT('0000'+CONVERT(VARCHAR,t.NumeroExpediente),5), '-', t.IdPeriodo,
	CASE WHEN COALESCE(t.CorrelativoVinculado,0)=0 THEN '' ELSE '-V-'+CONVERT(VARCHAR,t.CorrelativoVinculado) END) NombreExpediente,
	t.NumeroDiasAtencionSolicitado,
	COALESCE(t.ObservacionesDocumento,'')ObservacionesDocumento,
	COALESCE(t.AsuntoExpediente,'')AsuntoExpediente,
	COALESCE(t.IdCatalogoTipoTramite,0)IdCatalogoTipoTramite
from #tmp001_expediente765 t
cross apply(
    select t.plazoInicial - datediff(day, convert(date,t.NTFechaExpediente,103), getdate()) + General.ObtenerNumeroDiasSabadoDomingo(t.NTFechaExpediente,GETDATE()) diasSabDom
)fch

END TRY
BEGIN CATCH
	DECLARE @ERROR_NUMBER INT
	DECLARE @ERROR_SEVERITY INT
	DECLARE @ERROR_STATE INT
	DECLARE @ERROR_PROCEDURE VARCHAR(MAX)
	DECLARE @ERROR_LINE INT
	DECLARE @ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paObtenerExpedienteDocumentoOrigenDestino_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
go




EXECUTE Tramite.paObtenerExpedienteDocumentoOrigenDestino_arq 918092, 2026
EXECUTE Tramite.paObtenerExpedienteDocumentoOrigenDestino_arq
@pIdExpedienteDocumentoOrigenDestino = 7227686, --   656559, -- 918092,
@pIdPeriodo = 2026 -- 2023
