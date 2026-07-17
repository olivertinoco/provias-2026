USADO X:
tramite.paListarDocumentoPendienteEspecialistaV1_arq
Tramite.paListarDocumentoPendienteJefatura_arq
Tramite.paListarDetalleBusquedaExpedienteGeneral_arq
Tramite.paListarDocumentoPendienteCourrierJefatura
=============================================================
go
CREATE function [Tramite].[funPaseTieneAdjunto](
    @pIdExpedienteDocumentoOrigen INT
)RETURNS int
AS
BEGIN
	DECLARE @vTotal INT=0
	SELECT @vTotal=COUNT(IdExpedienteDocumentoOrigenEDO)
	FROM Tramite.ExpedienteDocumentoOrigenAdjunto  WITH (NOLOCK)
	WHERE EstadoAuditoria=1 and IdExpedienteDocumentoOrigenEDO=@pIdExpedienteDocumentoOrigen

	RETURN @vTotal
END

go


CREATE function [Tramite].[funDocumentoTieneAdjunto](
    @pIdExpedienteDocumento INT
)RETURNS int
AS
BEGIN
	DECLARE @vTotal INT=0
	SELECT @vTotal=COUNT(IdExpedienteDocumento)
	FROM Tramite.ExpedienteDocumentoAdjunto with (nolock)
	WHERE EstadoAuditoria=1 and IdExpedienteDocumento=@pIdExpedienteDocumento

	RETURN @vTotal
END

go




CREATE function [Tramite].[funMostrarAccionesPorDestino](
    @pIdExpedienteDocumentoOrigenDestino INT
)RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Lista  varchar(max)=''
	SELECT @Lista=CA.Descripcion +', '+ @Lista
	from  Tramite.ExpedienteDocumentoOrigenDestinoAccion A WITH (NOLOCK)
	INNER JOIN Tramite.Catalogo CA ON CA.IdCatalogo=A.IdCatalogoTipoAccion
	where A.IdExpedienteDocumentoOrigenDestino=@pIdExpedienteDocumentoOrigenDestino and A.EstadoAuditoria=1
	IF LEN(@Lista)>0 SET @Lista= LEFT(@Lista,LEN(@Lista)-1)

	RETURN @Lista
END
go

-- OUTER APPLY (
--     SELECT STRING_AGG(RTRIM(CA1.Descripcion), '', '') WITHIN GROUP(ORDER BY A1.IdExpedienteDocumentoOrigenDestinoAccion) AS Acciones
--     FROM Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_' + @vIdPeriodo + N' A1
--     INNER JOIN Tramite.Catalogo CA1 ON CA1.IdCatalogo = A1.IdCatalogoTipoAccion
--     WHERE A1.IdExpedienteDocumentoOrigenDestino = EDOD.IdExpedienteDocumentoOrigenDestino AND A1.EstadoAuditoria = 1
-- ) MAXDES



CREATE function [Tramite].[funEsPropioEspecialista](
    @pIdExpedienteDocumentoOrigenDestino INT,
    @pIdEmpresa int,
    @pIdArea int,
    @pIdCargo int,
    @pIdPersona int
)RETURNS int
AS
BEGIN
DECLARE @vPropio int=0
    IF(select COUNT(IdExpedienteDocumentoOrigenDestino)  from Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
    where
    EDOD.IdPersonaDestino=@pIdPersona and
    EDOD.IdCargoDestino=@pIdCargo and
    EDOD.IdAreaDestino=@pIdArea and
    EDOD.IdEmpresaDestino=@pIdEmpresa and
    EDOD.IdExpedienteDocumentoOrigenDestino=@pIdExpedienteDocumentoOrigenDestino)>0
    BEGIN
        SET @vPropio=1
    END
    RETURN @vPropio
END

go


CREATE function [Tramite].[funEsExtornable](
    @pIdExpedienteDocumentoOrigen INT,
    @pIdExpedienteDocumentoOrigenDestino INT
)RETURNS int
AS
BEGIN
DECLARE @vExtornable int=0

IF(SELECT COUNT(IdExpedienteDocumentoOrigenDestinoAnterior) FROM Tramite.ExpedienteDocumentoOrigenDestino WITH (NOLOCK)
	WHERE EstadoAuditoria=1 and IdExpedienteDocumentoOrigenDestinoAnterior=@pIdExpedienteDocumentoOrigenDestino AND COALESCE(FechaDestinoRecepciona,'')<>''
)=0
BEGIN
	SET @vExtornable=1
END

	RETURN @vExtornable
END
go
