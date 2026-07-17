USADO X:
Tramite.paListarDocumentoHojaRuta_arq
Tramite.paListarDocumentoOrigenDestinoHojaRuta_arq
Tramite.paListarDocumentoOrigenDestinoHojaRuta_BusquedaGeneral_arq
Tramite.paListarDocumentoHojaRuta_BusquedaGeneral_arq
===================================================================

CREATE function [Tramite].[funMostrarAccionesPorDestinoSoloCodigos](
@pIdExpedienteDocumentoOrigenDestino INT
)RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @Lista  varchar(max)=''
    SELECT @Lista= CONCAT( '(',case when CA.OrdenItem='22' then '2' else CA.OrdenItem end,')') +', '+ @Lista
    from  Tramite.ExpedienteDocumentoOrigenDestinoAccion A WITH (NOLOCK)
    INNER JOIN Tramite.Catalogo CA ON CA.IdCatalogo=A.IdCatalogoTipoAccion
    where A.IdExpedienteDocumentoOrigenDestino=@pIdExpedienteDocumentoOrigenDestino and A.EstadoAuditoria=1
    IF LEN(@Lista)>0 SET @Lista= LEFT(@Lista,LEN(@Lista)-1)

    RETURN @Lista
END
go



USADO X: Tramite.paListarMisDocumentosGeneradosJefatura_arq
=============================================================
CREATE function [Tramite].[funMostrarDesatinatarios]
(@pIdExpedienteDocumentoOrigen INT)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @Lista  varchar(max)=''

	SELECT
	@Lista=COALESCE(EDOD.DestinatarioDestino,COALESCE(P.NombreCompleto,'')+' '+COALESCE(EM.NombreEmpresa,'EXTERNO')+' '+COALESCE(A.NombreArea,'')+' ' +COALESCE(C.NombreCargo,''))+', '+@Lista
	FROM Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
	LEFT JOIN General.Cargo C ON C.IdCargo=EDOD.IdCargoDestino
	LEFT JOIN General.Area A ON A.IdArea=EDOD.IdAreaDestino
	LEFT JOIN General.Empresa EM ON EM.IdEmpresa=EDOD.IdEmpresaDestino
	LEFT JOIN General.Persona P ON P.IdPersona=EDOD.IdPersonaDestino
	WHERE EDOD.IdExpedienteDocumentoOrigen=@pIdExpedienteDocumentoOrigen AND EsInicial<>0 and EDOD.EstadoAuditoria=1

	IF LEN(@Lista)>0 SET @Lista= LEFT(@Lista,LEN(@Lista)-1)
	RETURN @Lista

END
