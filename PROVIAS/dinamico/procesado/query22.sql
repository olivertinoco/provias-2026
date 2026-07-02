-- set statistics io on
-- set statistics time on

-- CREATE PROCEDURE Tramite.paListarPendienteFirmaDigitalJefaturaV2_arq
declare
	@pIdArea int,
	@pIdUsuarioAuditoria int,
	@pCampoOrdenado varchar(50),
	@pTipoOrdenacion varchar(4),
	@pNumeroPagina INT,
	@pDimensionPagina  INT,
	@pBusquedaGeneral varchar(20)


-- AS
-- BEGIN
-- BEGIN TRY
SET LANGUAGE SPANISH
SET TRAN ISOLATION LEVEL READ UNCOMMITTED

create table #tmp001_expedienteFirma (
    IdExpediente int,
    IdExpedienteDocumento int,
    AbreviaturaSerieDocumentalExpediente varchar(10),
    NumeroExpediente int,
    IdPeriodo int,
    NumeroDocumento varchar(200),
    NFechaDocumento varchar(10),
    AsuntoDocumento varchar(8000),
    NumeroFoliosDocumento int,
    RutaArchivoDocumento varchar(150),
    ObservacionesDocumento varchar(4000),
    IdExpedienteDocumentoFirmante int,
    PosicionX int,
    PosicionY int,
    EsMiDocumento int,
    IdCatalogoTipoFirmante int,
    TipoFirma nvarchar(max),
    EsLiberado int,
    AreaEmisor varchar(500),
    PersonaEmisor varchar(400),
    FechaCreacionAuditoria datetime,
)

SELECT
@pIdArea=30,@pIdUsuarioAuditoria=53721,@pCampoOrdenado=NULL,@pTipoOrdenacion=NULL,@pNumeroPagina=1,@pDimensionPagina=10,@pBusquedaGeneral=NULL


SELECT * FROM TRAMITE.Expediente_Historico_2025 WHERE NombreExpediente = 'I-070615-2025'

SELECT FgEnEsperaFirmaDigital,* FROM TRAMITE.ExpedienteDocumento_Historico_2025
WHERE IdUsuarioEnProcesoFirma =@pIdUsuarioAuditoria AND EnProcesoFirma=1 AND EstadoAuditoria=1

select * from tramite.ExpedienteDocumentoFirmante_Historico_2025 EDF where EDF.IdArea = 30
AND EDF.EstadoAuditoria=1 AND EDF.FlagFirmado=0  AND EDF.IdCargo IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34))
AND EDF.NombreCompleto = 'MARIA ISABEL VASQUEZ ALDAVE'
-- return



    Declare @vSql nvarchar(max), @vIdPeriodo int = 2022
    declare @vAnno int = year(getdate()), @vItera int = 0, @vNuevoPeriodo int
	declare @vTotalItera int = @vAnno - @vIdPeriodo + 1
	declare @vcExpedienteRpta Nvarchar(4000) = ''

while(@vItera < @vTotalItera)begin
    select @vSql = ''
    select @vNuevoPeriodo = @vIdPeriodo + @vItera
    SELECT @vcExpedienteRpta = CASE WHEN @vNuevoPeriodo = @vAnno THEN N'' ELSE CONCAT(N'_historico_', @vNuevoPeriodo) END;

    select @vSql = N'\
    insert into #tmp001_expedienteFirma SELECT E.IdExpediente,ED.IdExpedienteDocumento,SD.AbreviaturaSerieDocumentalExpediente,E.NumeroExpediente,E.IdPeriodo,ED.NumeroDocumento,ED.NFechaDocumento,ED.AsuntoDocumento,ED.NumeroFoliosDocumento,ED.RutaArchivoDocumento,ED.ObservacionesDocumento,EDF.IdExpedienteDocumentoFirmante,EDF.PosicionX,EDF.PosicionY,
    CASE WHEN ED.IdCargoEmisor IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) and ED.IdAreaEmisor=@pIdArea and ED.IdEmpresaEmisor=2 THEN 1 ELSE 0 END EsMiDocumento,EDF.IdCatalogoTipoFirmante,F.FaltaFirma,
    (SELECT COUNT(IdExpedienteDocumento) FROM Tramite.ExpedienteDocumento'+ @vcExpedienteRpta +N' WHERE IdUsuarioEnProcesoFirma =@pIdUsuarioAuditoria AND EnProcesoFirma=1 AND IdExpedienteDocumento=ED.IdExpedienteDocumento AND EstadoAuditoria=1) EsLiberado,A.NombreArea AreaEmisor,P.NombreCompleto PersonaEmisor,ED.FechaCreacionAuditoria
    FROM Tramite.Expediente'+ @vcExpedienteRpta +N' E
    INNER JOIN Tramite.SerieDocumentalExpediente SD ON SD.IdSerieDocumentalExpediente=E.IdSerieDocumentalExpediente	AND E.ExpedienteAnulado=0
    INNER JOIN Tramite.ExpedienteDocumento'+ @vcExpedienteRpta +N' ED ON ED.IdExpediente=E.IdExpediente  and e.EstadoAuditoria=1 AND ED.EstadoAuditoria=1 AND ED.FgEnEsperaFirmaDigital=1
    INNER JOIN Tramite.ExpedienteDocumentoFirmante'+ @vcExpedienteRpta +N' EDF ON ED.IdExpedienteDocumento=EDF.IdExpedienteDocumento AND EDF.EstadoAuditoria=1 AND EDF.FlagFirmado=0 AND EDF.IdCargo IN(SELECT IdCargo FROM General.Cargo WHERE IdCatalogoTipoCargo in (32,33,34)) AND EDF.IdArea=@pIdArea
    INNER JOIN General.Area A ON ED.IdAreaEmisor=A.IdArea
    INNER JOIN General.Persona P ON ED.IdPersonaEmisor=p.IdPersona
    OUTER APPLY(
		select EB.IdExpedienteBloqueado,EB.FechaHoraBloquea
		from Tramite.ExpedienteBloqueado EB
		where ED.IdExpediente=EB.IdExpediente and EB.EstadoAuditoria=1 and EB.EstadoBloqueo=1
	)EB
	OUTER APPLY(
		select ''1'' PersonaVisualiza
		from Tramite.ExpedienteBloqueadoPersonaVisualiza EBPV
		inner join Seguridad.Usuario U on EBPV.IdPersonaVisualiza=U.IdPersona and U.IdUsuario=@pIdUsuarioAuditoria
		where EB.IdExpedienteBloqueado=EBPV.IdExpedienteBloqueado and EBPV.EstadoAuditoria=1
	)EB1
    CROSS APPLY(select(SELECT convert(varchar,count(*)) FROM Tramite.ExpedienteDocumentoFirmante'+ @vcExpedienteRpta +N' EDF
    WHERE EDF.EstadoAuditoria=1 and EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.FlagFirmado=0)+''¦''+
    (select STUFF((SELECT ''¬''+COALESCE(Ep.NombreCompleto,'''''''')
    FROM Tramite.ExpedienteDocumentoFirmante'+ @vcExpedienteRpta +N' EDF
    INNER JOIN RecursoHumano.visEmpleadoPerfilPersona EP ON EP.IdEmpleadoPerfil=EDF.IdEmpleadoPerfilFirmante
    WHERE EDF.EstadoAuditoria=1 and EDF.IdExpedienteDocumento=ED.IdExpedienteDocumento and EDF.FlagFirmado=0
    FOR XML PATH('''')), 1, 1, '''')) FaltaFirma
    )F WHERE ED.FlagParaDespacho=1 AND ED.FgEsObligatorioFirmaDigital=1 AND CONCAT(SD.AbreviaturaSerieDocumentalExpediente,RIGHT(1000000+E.NumeroExpediente,6), ''-'', E.IdPeriodo) LIKE  case when COALESCE(@pBusquedaGeneral,'''')<>'''' THEN ''%''+@pBusquedaGeneral +''%'' ELSE ''%'' END'

    exec sp_executesql @vSql, N'@pIdArea int,@pIdUsuarioAuditoria int,@pBusquedaGeneral varchar(20)',
    @pIdArea = @pIdArea, @pIdUsuarioAuditoria = @pIdUsuarioAuditoria, @pBusquedaGeneral = @pBusquedaGeneral

    select @vItera+=1
end


select
IdExpediente,
IdExpedienteDocumento,
AbreviaturaSerieDocumentalExpediente,
NumeroExpediente,
IdPeriodo,
NumeroDocumento,
NFechaDocumento,
AsuntoDocumento,
NumeroFoliosDocumento,
RutaArchivoDocumento,
ObservacionesDocumento,
IdExpedienteDocumentoFirmante,
PosicionX,
PosicionY,
EsMiDocumento,
IdCatalogoTipoFirmante,
TipoFirma,
EsLiberado,
AreaEmisor,
PersonaEmisor,
FechaCreacionAuditoria
from #tmp001_expedienteFirma


-- set statistics io off
-- set statistics time off
